require 'net/http'
require 'socket'
require "src/status"
require "src/erros_rapidshare"
require "src/server_rs"
require "src/server_mu"

class Link
  attr_accessor :link, :host, :path, :ip, :uri, :id_link, :id_pacote, \
    :completado, :tamanho, :id_status, :tentativas, :max_tentativas, \
    :data_inicio, :data_fim, :testado

  def initialize link
    @link = link.strip
    @uri = URI.parse link
    @host = @uri.host
    @path = @uri.path
    set_ip
    @tentativas = 0
    @max_tentativas = 5
    @completado = false
    @tamanho = 0
    @id_status = Status::AGUARDANDO
    @data_fim = nil
    @data_inicio = nil
    @testado = false
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
    db_statement_do(sql)
  end

  # Traduz hostname da URL para ip.
  # Retorno: String IP
  def set_ip
    begin
      @ip = IPSocket.getaddress @host
    rescue Exception
      if @host == "rapidshare.com" or @host == "www.rapidshare.com"
        @ip = "195.122.131.2"
      elsif @host =~ /rs\d+.rapidshare.com/
        server_rs = ServerRS.new(@host.scan(/\d+/)[0].to_i)
        @ip = server.ip
      elsif @host =~ /wwwq\d+.megaupload.com/
        server_mu = ServerMU.new(@host.scan(/\d+/)[0].to_i)
        @ip = server.ip
      else
        raise
      end
    end
  end

  def <=>(object)
    return self.id_link <=> object.id_link
  end

  # Verifica o estado do link, podendo ele ser:
  #   OFFLINE
  #   ONLINE
  #   INTERROMPIDO
  #   TESTANDO
  def test
    begin
      to_log "Testando link: #{@link}"
      unless @link =~ /http:\/\/\S+\/.+/
        to_log "ERRO: Link inválido evitado."
        @id_status = Status::OFFLINE
        @testado = true
        @data_inicio = timestamp Time.now
        update_db
        return
      end
      @id_status = Status::TESTANDO
      @data_inicio = timestamp Time.now
      update_db
      
      http = Net::HTTP.new(@ip)
      http.read_timeout = 15 #segundos
      begin
        headers, body = http.get(@path)
        unless headers.code == "200"
          to_log "Não foi possível carregar a página."
          to_log "#{headers.code} - #{headers.message}"
          if retry_ == Status::OFFLINE
            return
          end
        end
      end while headers.code != "200"
      @tentativas = 0

      # Requisitando pagina de download
      if error body or error2 body
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

  def retry_
    @tentativas += 1
    if @tentativas > @max_tentativas
      @id_status = Status::OFFLINE
      @testado = true
      update_db
      return Status::OFFLINE
    end
  end

  def download
    begin
      to_log("Tentando baixar o link: #{@link}")
      @id_status = Status::TENTANDO
      @tentativas = 0
      update_db
      http = Net::HTTP.new(@ip)
      http.read_timeout = 15 #segundos
      to_debug 'Abrindo conexão HTTP...'
      begin
        headers, body = http.get(@path)
        unless headers.code == "200"
          to_log "Não foi possível carregar a página."
          to_log "#{headers.code} - #{headers.message}"
          if retry_ == Status::OFFLINE
            return
          end
        end
      end while headers.code != "200"
      @tentativas = 0

      # Requisitando pagina de download
      to_debug 'Conexão HTTPOK 200.'

      if error body or blocked body
        @id_status = Status::OFFLINE
        update_db
        return
      end

      begin
        servidor_host = reconhecer_servidor body
        if servidor_host == nil
          if retry_ == Status::OFFLINE
            return
          end
        end
      end while servidor_host == nil
      server = Server.new(servidor_host.scan(/\d+/)[0].to_i)
      @tentativas = 0

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
      resposta = Net::HTTP.post_form(URI.parse("http://#{server.ip}#{@path}"), {'dl.start'=>'Free'})
      resposta = resposta.body
      
      if lot_of_users(resposta) or respaw(resposta) or waiting(resposta) or \
          get_no_slot(resposta) or simultaneo(resposta) or get_justify(resposta)
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
      baixou = system("curl -LO #{download}")
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