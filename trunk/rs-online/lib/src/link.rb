require 'net/http'
require 'socket'
require "uri"
require "httpclient"
require "src/status"
require "src/banco"
require "src/error_rs"
require "src/error_mu"
require "src/server_rs"
require "src/server_mu"
require "src/tipo_servidor"
require "src/megaupload"
require "src/rapidshare"

class Link
  attr_accessor :link, :path, :ip, :uri_original, :uri_parsed, :id_link, :id_pacote, \
    :completado, :tamanho, :id_status, :tentativas, :max_tentativas, \
    :data_inicio, :data_fim, :testado, :tipo

  def initialize link
    @link = link.strip
    @uri_original = URI.parse link
    @id_link = nil
    set_ip
    @tentativas = 0
    @max_tentativas = 20
    @completado = false
    @tamanho = 0
    @id_status = Status::AGUARDANDO
    @data_fim = nil
    @data_inicio = nil
    @testado = false
    if @uri_original.host =~ /megaupload/
      @tipo = TipoServidor::MU
    elsif @uri_original.host =~ /rapidshare/
      @tipo = TipoServidor::RS
    else
      @tipo = nil
      to_log("Tipo do host não detectado.")
    end
  end

  def get_body
    http = HTTPClient.new
    #    http.timeout_scheduler 15 #segundos
    begin
      response = http.get(@uri_parsed)
      unless response.header.status_code == 200
        to_log "Não foi possível carregar a página."
        to_log "#{response.header.status_code} - #{response.header.reason_phrase}"
        if retry_ == Status::OFFLINE
          return
        end
      end
    end while response.header.status_code != 200
    @tentativas = 0
    response.body.content
  end

  # Escreve os dados no BD.
  def update_db
    sql = "UPDATE rs.link SET "
    sql += "tamanho = #{@tamanho}, " unless @tamanho == nil
    sql += "testado = #{@testado}, " unless @testado == nil
    sql += "data_inicio = '#{@data_inicio}', " unless @data_inicio == nil
    sql += "data_fim = '#{@data_fim}', " unless @data_fim == nil
    sql += "completado = '#{@completado}', " unless @completado == nil
    sql += "id_status = #{@id_status} "
    sql += "WHERE id_link = #{@id_link}"
    Banco.instance.db_connect.do(sql)
  end

  # Traduz hostname da URL para ip.
  # Retorno: String IP
  def set_ip
    begin
      @ip = Resolv::DNS.new
      @ip = @ip.getaddress(@uri_original.host)
      @uri_parsed = @uri_original.clone
      @uri_parsed.host = @ip.to_s
    rescue Exception
      if @uri_original.host == "rapidshare.com" or @uri_original.host == "www.rapidshare.com"
        @ip = "195.122.131.2"
      elsif @uri_original.host == "megaupload.com" or @uri_original.host == "www.megaupload.com"
        @ip = "174.140.154.25"
      elsif @uri_original.host =~ /rs\d+\.rapidshare\.com/
        server = ServerRS.new(@uri_original.host.scan(/\d+/)[0].to_i)
        @ip = server.ip
      elsif @uri_original.host =~ /www\d+\.megaupload\.com/
        server = ServerMU.new(@uri_original.host.scan(/\d+/)[0].to_i)
        @ip = server.ip
      else
        raise
      end
    end
  end

  def <=>(object)
    return self.id_link <=> object.id_link
  end

  def test
    if @tipo == TipoServidor::RS
      test_rs
    elsif @tipo == TipoServidor::MU
      test_mu
    else
      to_log("Erro ao testar tipo de link nil.")
    end
  end

  def download
    if @tipo == TipoServidor::RS
      download_rs
    elsif @tipo == TipoServidor::MU
      download_mu
    else
      to_log("Erro ao baixar tipo de link nil.")
    end
  end

  def retry_
    @tentativas += 1
    if @tentativas > @max_tentativas
      @id_status = Status::OFFLINE
      @testado = true
      update_db
      return Status::OFFLINE
    end
    sleep 1
  end

  # Verifica o estado do link, podendo ele ser:
  #   OFFLINE
  #   ONLINE
  #   INTERROMPIDO
  #   TESTANDO
  # => Rapidshare test
  def test_rs
    begin
      to_log "Testando link: #{@link}"
      unless @link =~ /http:\/\/\S+\/.+/
        to_log "ERRO: Sintaxe do link inválido. Evitado."
        @id_status = Status::OFFLINE
        @testado = true
        @data_inicio = timestamp Time.now
        update_db
        return
      end
      @id_status = Status::TESTANDO
      @data_inicio = timestamp Time.now
      update_db
      
      body = get_body

      # Requisitando pagina de download
      if ErrorRS::error body or ErrorRS::error2 body
        @id_status = Status::OFFLINE
        @testado = true
        update_db
        return
      end
      ## Captura tamanho do arquivo
      @tamanho = body.scan(/\| (\d+) KB/i)[0][0]
      if @tamanho == nil # Testa se identificou o tamanho
        to_log 'Não foi possível capturar o tamanho.'
        # Download ainda pode ser feito.
      else
        @tamanho = @tamanho.to_i
        to_log "Tamanho #{@tamanho} KB ou #{sprintf "%.2f MB", @tamanho/1024.0}"
        @id_status = Status::ONLINE
        @testado = true
        update_db
      end
      return
    rescue Timeout::Error
      to_log "Tempo de requisição esgotado. Tentando novamente."
      retry
    rescue Exception
      @id_status = Status::INTERROMPIDO
      @testado = false
      update_db
      raise
    end
  end

  # => Rapidshare download
  def download_rs
    begin
      to_log("Tentando baixar o link: #{@link}")
      @id_status = Status::TENTANDO
      update_db

      body = get_body

      # Requisitando pagina de download
      to_debug 'Conexão HTTPOK 200.'

      if ErrorRS::error body or ErrorRS::blocked body
        @id_status = Status::OFFLINE
        update_db
        return
      end

      begin
        servidor_host = Rapidshare::reconhecer_servidor body
        if servidor_host == nil
          if retry_ == Status::OFFLINE
            return
          end
        end
      end while servidor_host == nil
      server = ServerRS.new(servidor_host.scan(/\d+/)[0].to_i)

      ## Captura tamanho do arquivo
      expressao = body.scan(/\| (\d+) KB/i)[0][0]
      if expressao == nil # Testa se identificou o tamanho
        to_log('Não foi possível capturar o tamanho.')
        retry_
        return
      else
        @tamanho = expressao.to_i
        to_debug("Tamanho #{@tamanho} KB ou #{sprintf("%.2f MB", @tamanho/1024.0)}")
      end

      ## Mandando requisição POST
      to_debug('Enviando requisição de download...')
      resposta = Net::HTTP.post_form(URI.parse("http://#{server.ip}#{@uri_original.path}"), {'dl.start'=>'Free'})
      resposta = resposta.body
      
      if ErrorRS::lot_of_users(resposta) or ErrorRS::respaw(resposta) or \
          ErrorRS::waiting(resposta) or ErrorRS::get_no_slot(resposta) or \
          ErrorRS::simultaneo(resposta) or ErrorRS::get_justify(resposta)
        retry_
        return
      end

      ## Captura tempo de espera
      expressao = resposta.scan(/var c=(\d+)/)[0][0]
      if expressao == nil # Testa se identificou o contador
        to_log('Não foi possível capturar o contador.')
        retry_
        return
      end
      tempo_inteiro = expressao.to_i
      time = Time.local(0) + tempo_inteiro
      to_debug(time.strftime("Contador identificado: %Hh %Mm %Ss."))
      contador(tempo_inteiro, "O download iniciará em %Hh %Mm %Ss.")

      expressao = resposta.scan(/dlf.action=\\\'\S+\\/)[0]
      expressao.gsub!("dlf.action=\\'","").gsub!("\\","")
      real_uri = URI.parse expressao
      download = "http://#{server.ip}#{real_uri.path}"

      to_log("Baixando: #{download}")
      time_inicio = Time.now
      @data_inicio = timestamp time_inicio
      @id_status = Status::BAIXANDO
      update_db
      ## Download com curl
      baixou = system("curl", "-LO", "#{download}")
      time_fim = Time.now
      @data_fim = timestamp time_fim
      duracao = Time.local(0) + (time_fim - time_inicio)
      duracao_str = duracao.strftime("%Hh %Mm %Ss")
      if baixou
        to_log("D. link concluído com sucesso em #{duracao_str}.")
        to_log("Velocidade média do link foi de #{sprintf("%.2f KB/s", @tamanho.to_i/(time_fim - time_inicio))}.")
        @id_status = Status::BAIXADO
        @completado = true
      else
        to_log("Download do link falhou com #{duracao_str} decorridos.")
        @id_status = Status::TENTANDO
      end
      update_db
      return
    rescue Timeout::Error
      to_log("Tempo de requisição esgotado. Tentando novamente.")
      retry
    rescue Exception
      @id_status = Status::INTERROMPIDO
      raise
    end
  end


  # => Megaupload test
  def test_mu
    begin
      to_log "Testando link: #{@link}"
      unless @link =~ /http:\/\/\S+\/.+/
        to_log "ERRO: Sintaxe do link inválido. Evitado."
        @id_status = Status::OFFLINE
        @testado = true
        @data_inicio = timestamp Time.now
        update_db
        return
      end
      @id_status = Status::TESTANDO
      @data_inicio = timestamp Time.now
      update_db
      body = get_body
      
      # Verificando erros
      if ErrorMU::indisponivel(body) or ErrorMU::deletado(body) or ErrorMU::invalido(body)
        @id_status = Status::OFFLINE
        @testado = true
        update_db
        return
      end

      mu = Megaupload.new body
      ## Captura tamanho do arquivo
      @tamanho = mu.get_size
      if @tamanho == nil
        to_log 'Não foi possível capturar o tamanho.'
        # Download ainda pode ser feito.
      else
        to_log "Tamanho #{@tamanho} KB ou #{sprintf "%.2f MB", @tamanho/1024.0}"
        @id_status = Status::ONLINE
        @testado = true
        update_db
      end
      return
    rescue Timeout::Error
      to_log "Tempo de requisição esgotado. Tentando novamente."
      retry
    rescue Exception => e
      to_log "Erro: #{e.message}"
      ##\nBacktrace: #{e.backtrace.join("\n")}"
      @id_status = Status::INTERROMPIDO
      @testado = false
      update_db
      raise
    end
  end

  # => Megaupload download
  def download_mu
    begin
      to_log("Tentando baixar o link: #{@link}")
      @id_status = Status::TENTANDO
      update_db

      body = get_body

      if ErrorMU::indisponivel(body) or ErrorMU::deletado(body) or ErrorMU::invalido(body)
        @id_status = Status::OFFLINE
        update_db
        return
      end

      mu = Megaupload.new(body)

      ## Captura tamanho do arquivo
      @tamanho = mu.get_size
      if @tamanho == nil
        to_log('Não foi possível capturar o tamanho.')
        retry_
        return
      else
        to_debug("Tamanho #{@tamanho} KB ou #{sprintf("%.2f MB", @tamanho/1024.0)}")
      end

      ## Captura captchacode
      captchacode = mu.get_captchacode
      if captchacode == nil
        to_log('Não foi possível capturar o captchacode.')
        retry_
        return
      else
        to_debug "captchacode reconhecido => #{captchacode}"
      end

      ## Captura megavar
      megavar = mu.get_megavar
      if megavar == nil
        to_log('Não foi possível capturar o megavar.')
        retry_
        return
      else
        to_debug "megavar reconhecido => #{megavar}"
      end

      ## Captura captcha
      captcha = mu.get_captcha
      if captcha == nil or captcha.size != 4
        to_log('Não foi possível capturar o captcha.')
        retry_
        return
      else
        to_log "Captcha reconhecido => #{captcha}"
      end

      ## Requisição POST
      to_debug('Enviando requisição de download...')
      hash = {
        "captchacode" => captchacode,
        "megavar" => megavar,
        "captcha" => captcha
      }
      post = HTTPClient.new
      response = post.post(@uri_parsed, hash)
      unless response.header.status_code == 200
        to_log "Erro no POST."
        retry_
      end
      response = response.body.content
      # Fim da requisição POST

      mu = Megaupload.new(response)
      
      if mu.captcha_recognized?
        to_debug "Captcha está correto."        
      else
        to_log('ERRO: Captcha não está correto.')
        retry_
        return
      end

      ## Captura link do download
      download = mu.get_downloadlink
      if download == nil
        to_log('Não foi possível capturar o link para download.')
        retry_
        return
      end

      begin
        servidor_host = mu.reconhecer_servidor
        if servidor_host == nil
          if retry_ == Status::OFFLINE
            return
          end
        end
      end while servidor_host == nil
      server = ServerMU.new(servidor_host)

      download.gsub!(/www\d+\.megaupload.com/, server.ip)
      to_log("Baixando: #{download}")

      ## Captura tempo de espera
      count = mu.get_countdown
      if count == nil # Testa se identificou o contador
        to_log('Não foi possível capturar o contador.')
        retry_
        return
      end
      time = Time.local(0) + count
      to_debug(time.strftime("Contador identificado: %Hh %Mm %Ss."))
      contador(count, "O download iniciará em %Hh %Mm %Ss.")

      to_log("Baixando: #{download}")
      time_inicio = Time.now
      @data_inicio = timestamp time_inicio
      @id_status = Status::BAIXANDO
      update_db
      ## Download com curl
      baixou = system("curl -LOC - \"#{download}\"")
      time_fim = Time.now
      @data_fim = timestamp time_fim
      duracao = Time.local(0) + (time_fim - time_inicio)
      duracao_str = duracao.strftime("%Hh %Mm %Ss")
      if baixou
        to_log("D. link concluído com sucesso em #{duracao_str}.")
        to_log("Velocidade média do link foi de #{sprintf("%.2f KB/s", @tamanho.to_i/(time_fim - time_inicio))}.")
        @id_status = Status::BAIXADO
        @completado = true
      else
        to_log("Download do link falhou com #{duracao_str} decorridos.")
        @id_status = Status::TENTANDO
      end
      update_db
      return
    rescue Timeout::Error
      to_log("Tempo de requisição esgotado. Tentando novamente.")
      retry
    rescue Exception
      @id_status = Status::INTERROMPIDO
      raise
    end
  end

end