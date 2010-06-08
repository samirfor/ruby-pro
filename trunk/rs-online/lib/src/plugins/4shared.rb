require "resolv"

class FourShared < Link

  attr_reader :body

  def initialize body
    @body = body
  end

  def get_ticket
    begin
      ticket = @body.scan(/<a href=\"(http:\/\/[\w\.]*4shared(-china)?\.com\/get[^\;\"]*).*\" class=\".*dbtn.*\" tabindex=\"1\"/i)[0][0]
    rescue
    end
    if ticket == nil or ticket == []
      # talvez download direto
      begin
        ticket = @body.scan(/startDownload.*window\.location.*(http:\/\/.*)\"/i)[0]
      rescue
        return nil
      end
      return nil if ticket == nil or ticket == []
    end
    ticket
  end
  def file_not_found?
    if avaliable? and get_size != nil
      false
    else
      true
    end
  end
  def avaliable?
    expressao = @body.scan(/<title>4shared.com.*download.*<\/title>/i)
    if expressao == nil or expressao == []
      false
    else
      true
    end
  end

  def linkerror?
    expressao = @body.scan(/linkerror.jsp/i)
    if expressao == nil or expressao == []
      false
    else
      true
    end
  end
  def get_size
    begin
      tamanho = @body.scan(/<b>Size:<\/b><\/td>.*<.*>(.*) KB<\/td>/i)[0]
    rescue
      return nil
    end
    return nil if tamanho == nil or tamanho == []
    tamanho.delete(",").to_i
  end
  def get_downloadlink
    begin
      search = @body.scan(/id=\'divDLStart\' >.*<a href=\'(.*)\'/i)[0]
    rescue
    end
    begin
      search = @body.scan(/(\'|\")(http:\/\/dc\d+\.4shared(-china)?\.com\/download\/\d+\/.*\/.*)(\'|\")/i)[1]
    rescue
      nil
    end if search == nil
    return nil if search == []
    return search
  end
  def get_countdown
    begin
      search = @body.scan(/var c = (\d+);/)[0]
    rescue
      return 40
    end
    if search == nil or search == []
      return 40
    end
    search.to_i
  end
  # => 4shared test
  def test
    begin
      Historico.to_log "Testando link: #{@link}"
      unless @link =~ /http:\/\/\S+\/.+/
        Historico.to_log "ERRO: Sintaxe do link inválido. Evitado."
        @id_status = Status::OFFLINE
        @testado = true
        @data_inicio = StrTime.timestamp Time.now
        update_db
        return
      end

      # Corrige link
      @link.gsub!(/red\.com\/(get|audio|video)/, "red.com/file")

      @id_status = Status::TESTANDO
      @data_inicio = StrTime.timestamp Time.now
      update_db
      body = get_body

      fs = FourShared.new body

      if fs.file_not_found?
        @id_status = Status::OFFLINE
        @testado = true
        update_db
        return
      end

      ## Captura tamanho do arquivo
      @tamanho = fs.get_size
      if @tamanho == nil
        Historico.to_log 'Não foi possível capturar o tamanho.'
        # Download ainda pode ser feito.
      else
        Historico.to_log "Tamanho #{@tamanho} KB ou #{sprintf "%.2f MB", @tamanho/1024.0}"
        @id_status = Status::ONLINE
        @testado = true
        update_db
      end
      return
    rescue Timeout::Error
      Historico.to_log "Tempo de requisição esgotado. Tentando novamente."
      retry
    rescue Exception => e
      Historico.to_log "Erro: #{e.message}\nBacktrace: #{e.backtrace.join("\n")}"
      @id_status = Status::INTERROMPIDO
      @testado = false
      update_db
      raise
    end
  end
  # => 4shared download
  def download
    begin
      Historico.to_log("Tentando baixar o link: #{@link}")
      @id_status = Status::TENTANDO
      update_db

      body = get_body
      fs = FourShared.new body

      if fs.file_not_found?
        @id_status = Status::OFFLINE
        @testado = true
        update_db
        return
      end

      ## Captura tamanho do arquivo
      @tamanho = fs.get_size
      if @tamanho == nil
        Historico.to_log('Não foi possível capturar o tamanho.')
        retry_
        return
      else
        to_debug("Tamanho #{@tamanho} KB ou #{sprintf("%.2f MB", @tamanho/1024.0)}")
      end

      ticket = fs.get_ticket
      if ticket == nil
        Historico.to_log('Não foi possível o ticket.')
        retry_
        return
      end

      to_debug('Enviando requisição de download...')
      request = Link.new(ticket)
      response = request.get_body
      fs = FourShared.new(response)

      if fs.linkerror?
        Historico.to_log('Arquivo não encontrado no servidor.')
        retry_
        return
      end

      ## Captura link do download
      download = fs.get_downloadlink
      if download == nil
        Historico.to_log('Não foi possível capturar o link para download.')
        retry_
        return
      end

      begin
        servidor_host = fs.reconhecer_servidor
        if servidor_host == nil
          if retry_ == Status::OFFLINE
            return
          end
        end
      end while servidor_host == nil
      server = ServerFS.new(servidor_host)

      download.gsub!(/dc\d+\.4shared.com/, server.ip)

      ## Captura tempo de espera
      count = fs.get_countdown
      if count == nil # Testa se identificou o contador
        Historico.to_log('Não foi possível capturar o contador.')
        retry_
        return
      end
      time = Time.local(0) + count
      to_debug(time.strftime("Contador identificado: %Hh %Mm %Ss."))
      contador(count, "O download iniciará em %Hh %Mm %Ss.")

      Historico.to_log("Baixando: #{download}")
      time_inicio = Time.now
      @data_inicio = StrTime.timestamp time_inicio
      @id_status = Status::BAIXANDO
      update_db
      ## Download com curl
      baixou = system("curl -LO \"#{download}\"")
      time_fim = Time.now
      @data_fim = StrTime.timestamp time_fim
      duracao = Time.local(0) + (time_fim - time_inicio)
      duracao_str = duracao.strftime("%Hh %Mm %Ss")
      if baixou
        Historico.to_log("D. link concluído com sucesso em #{duracao_str}.")
        Historico.to_log("Velocidade média do link foi de #{sprintf("%.2f KB/s", @tamanho.to_i/(time_fim - time_inicio))}.")
        @id_status = Status::BAIXADO
        @completado = true
      else
        Historico.to_log("Download do link falhou com #{duracao_str} decorridos.")
        @id_status = Status::TENTANDO
      end
      update_db
      return
    rescue Timeout::Error
      Historico.to_log("Tempo de requisição esgotado. Tentando novamente.")
      retry
    rescue Exception
      @id_status = Status::INTERROMPIDO
      raise
    end
  end
end
