require 'net/http'
require 'socket'

class Link
  attr_accessor :link, :host, :path, :ip, :uri, :id_link, :id_pacote, :completado, :tamanho, :id_status, :tentativas, :max_tentativas, :data_inicio, :data_fim

  #  def initialize(id_link, link, id_pacote, id_status)
  #    @id_link = id_link
  #    @link = link
  #    @id_pacote = id_pacote
  #    @id_status = id_status
  #  end

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
    @data_fim = '2000-01-01'
    @data_inicio = '2000-01-01'
  end

  def fill_db id_link, id_pacote, id_status
    @id_link = id_link
    @id_pacote = id_pacote
    @id_status = id_status
  end

  # Traduz hostname da URL para ip.
  # Retorno: String IP
  def set_ip
    begin
      @ip = IPSocket.getaddress @host
    rescue Exception
      @ip = "195.122.131.2" if @host == "rapidshare.com" or @host == "www.rapidshare.com"
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
      to_log "Testando link: " + @link
      unless @link =~ /http:\/\/\S+\/.+/
        to_log "ERRO: Link inválido evitado."
        @id_status = Status::OFFLINE
        update_db
        return
      end
      @id_status = Status::TESTANDO
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
        update_db
      end
      return
    rescue Timeout::Error
      to_log "Tempo de requisição esgotado. Tentando novamente."
      retry
    rescue Exception
      @id_status = Status::INTERROMPIDO
      update_db
      raise
    end
  end

  def retry_
    @tentativas += 1
    if @tentativas > @max_tentativas
      @id_status = Status::OFFLINE
      update_db
      return Status::OFFLINE
    end
  end

  def download
    begin
      to_log("Baixando o link: #{@link}")
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
      resposta = Net::HTTP.post_form(URI.parse("http://#{@ip}#{@path}"), {'dl.start'=>'Free'})
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
      real_ip = IPSocket.getaddress real_uri.host
      download = "http://#{real_ip}#{real_uri.path}"

      to_log("Baixando: #{download}")
      @data_inicio = Time.now
      @id_status = Status::BAIXANDO
      update_db
      ## Download com curl
      baixou = system("curl -LO #{download}")
      @data_fim = Time.now
      duracao = Time.local(0) + (@data_fim - @data_inicio)
      duracao_str = duracao.strftime("%Hh %Mm %Ss")
      if baixou
        to_log("Download concluido com sucesso em #{duracao_str}.")
        to_log("Velocidade média foi de #{sprintf("%.2f KB/s", @tamanho.to_i/(@data_fim - @data_inicio))}.")
        @id_status = Status::BAIXADO
      else
        to_log("Download falhou com #{duracao_str} decorridos.")
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

  def update_db
    sql = "UPDATE rs.link SET "
    sql += "id_status = #{@id_status}, "
    sql += "tamanho = #{@tamanho}, "
    sql += "data_inicio = '#{@data_inicio}', "
    sql += "data_fim = '#{@data_fim}', "
    sql += "completado = '#{@completado}' "
    sql += "WHERE id_link = #{@id_link}"
    db_statement_do(sql)
  end
end