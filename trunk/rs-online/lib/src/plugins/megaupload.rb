require "src/captcha"
require "src/verbose"
require "src/timestamp"
require "resolv"
require "uri"

class Megaupload < Link

  attr_accessor :body, :megavar, :captchacode, :captcha

  def initialize link
    super
  end

  def get_captcha
    begin
      expressao = @body.scan(/http:\/\/(\S+)\.megaupload.com\/gencap.php\?(\S+)\.gif/)[0]
    rescue
      return nil
    end
    unless expressao == nil
      url = "http://#{expressao[0]}.megaupload.com/gencap.php?#{expressao[1]}.gif"
      Verbose.to_debug("URL da imagem: #{url}")
      dns = Resolv::DNS.new
      expressao[0] = dns.getaddress("#{expressao[0]}.megaupload.com").to_s
      url = "http://#{expressao[0]}/gencap.php?#{expressao[1]}.gif"
      Verbose.to_debug("URL da imagem: #{url}")
      path = "/tmp/captcha.gif"
      Captcha::save(url, path)
      @captcha = Captcha::recognize(path)
    else
      @captcha = nil
    end
  end
  def get_captchacode
    begin
      @captchacode = @body.scan(/name=\"captchacode\" value=\"(.+)\">/)[0][0]
    rescue
      return nil
    end
    return @captchacode
  end
  def get_megavar
    begin
      @megavar = @body.scan(/name=\"megavar\" value=\"(.+)\">/)[0][0]
    rescue
      return nil
    end
    return @megavar
  end
  def get_size
    begin
      @tamanho = @body.scan(/font style=.*File size.*>(.+)<\/font/i)[0][0]
    rescue
      return nil
    end
    unless @tamanho == nil
      @tamanho = @tamanho.to_f*1024
      @tamanho = @tamanho.to_i
    end
    return @tamanho
  end
  def get_countdown
    begin
      @waittime = @body.scan(/count=(\d+);/)[0][0]
    rescue
      return nil
    end
    if @waittime == nil or @waittime == []
      return nil
    end
    @waittime = @waittime.to_i
  end
  def get_filename
    begin
      @filename = @body.scan(/<font style=.*>Filename:<\/font> <font style=.*>(.*)<\/font><br>/)[0][0]
    rescue
      @filename = nil
    end
    @filename = nil if @filename == []
    @filename
  end
  def get_downloadlink
    begin
      @downloadlink = @body.scan(/downloadlink.*href=\"(.*)\" onclick/i)[0][0]
    rescue
      return nil
    end
    return @downloadlink
  end
  def captcha_recognized?
    search = @body.scan(/post/i)
    if search == nil or search == []
      return true
    else
      return false
    end
  end

  # Método para reconhecimento do servidor de download
  def recognize_server
    begin
      servidor_host = @body.scan(/http:\/\/www(\d+)\.megaupload\.com\/files/i)[0][0]
    rescue
      return nil
    end
    if servidor_host == nil
      Verbose.to_log("Não foi possível reconhecer o servidor.")
      Verbose.to_log("Verifique se a URL está correta. Evitando ...")
      return nil
    end
    Verbose.to_debug("Servidor www#{servidor_host}.megaupload.com identificado.")
    servidor_host.to_i
  end
  def regex string
    expressao = nil
    expressao = @body.scan(/#{string}/i)[0]
    if expressao == nil
      return false
    else
      return true
    end
  end
  def invalid
    if regex("invalid link")
      Verbose.to_log("Link inválido reconhecido pelo MU.")
      return true
    else
      return false
    end
  end
  def deleted
    if regex("The file has been deleted because it was violating")
      Verbose.to_log("Este arquivo foi deletado porque violou os Termos de Serviço do MU.")
      return true
    else
      return false
    end
  end
  def temp_unavaliable
    if regex("The file you are trying to access is temporarily") or \
        regex("No htmlCode read") or \
        regex("This service is temporarily not available from your service area")
      Verbose.to_log "O arquivo que está tentando acessar está temporariamente inacessível."
      return true
    else
      return false
    end
  end
  def ip_block
    if regex("A temporary access restriction is place") or \
        regex("We have detected an elevated") or \
        regex('location=\'http:\/\/www\.megaupload\.com\/\?c=msg')
      wait = @body.scan(/Please check back in (\d+) minutes/i)[0][0]
      unless wait == nil
        wait = wait.to_i
        @waittime = wait * 60
        Verbose.to_log "MU bloqueou esse Ip por #{wait} minutos."
      else
        Verbose.to_log 'Waitime não funcionou! BUG SEVERO!'
      end
      Core.contador(@waittime, "Aguardando %Hh %Mm %Ss.")
    end
  end
  def big_files
    if regex("trying to download is larger than")
      Verbose.to_log("MU: Arquivos acima de 1GB precisam de conta premium.")
      return true
    else
      return false
    end
  end
  def error?
    if temp_unavaliable or deleted or invalid or big_files
      true
    else
      false
    end
  end
  def test
    begin
      Verbose.to_log "Testando link: #{@link} | Tentativa #{@tentativas} de #{@max_tentativas}."
      return unless http_valid?
      @id_status = Status::TESTANDO
      @data_inicio = StrTime.timestamp Time.now
      update_db
      
      @body = get_body
      # Verificando erros
      if self.error?
        @id_status = Status::OFFLINE
        @testado = true
        update_db
        return
      end

      ## Captura nome do arquivo
      self.get_filename
      if @filename == nil
        Verbose.to_log('Não foi possível capturar o nome do arquivo.')
      else
        Verbose.to_log("Nome do arquivo: #{@filename}")
        update_db
      end

      ## Captura tamanho do arquivo
      self.get_size
      if @tamanho == nil
        Verbose.to_log 'Não foi possível capturar o tamanho.'
        # Download ainda pode ser feito.
      else
        Verbose.to_log "Tamanho #{@tamanho} KB ou #{sprintf "%.2f MB", @tamanho/1024.0}"
        @id_status = Status::ONLINE
        @testado = true
        update_db
      end
      return
    rescue Timeout::Error
      Verbose.to_log "Tempo de requisição esgotado. Tentando novamente."
      retry
    rescue Exception => e
      Verbose.to_log "Erro: #{e.message}\nBacktrace: #{e.backtrace.join("\n")}"
      @id_status = Status::INTERROMPIDO
      @testado = false
      update_db
      raise
    end
  end
  def get_ticket
    begin
      Verbose.to_log("Tentando baixar o link: #{@link} | Tentativa #{@tentativas} de #{@max_tentativas}.")
      @id_status = Status::TENTANDO
      update_db

      @body = get_body
      if self.error?
        @id_status = Status::OFFLINE
        update_db
        return nil
      end

      ## Captura nome do arquivo
      self.get_filename
      if @filename == nil
        Verbose.to_log('Não foi possível capturar o nome do arquivo.')
      else
        Verbose.to_log("Nome do arquivo: #{@filename}")
      end

      ## Captura tamanho do arquivo
      self.get_size
      if @tamanho == nil
        Verbose.to_log('Não foi possível capturar o tamanho.')
        retry_
        return nil
      else
        Verbose.to_debug("Tamanho #{@tamanho} KB ou #{sprintf("%.2f MB", @tamanho/1024.0)}")
      end

      ## Captura captchacode
      self.get_captchacode
      if @captchacode == nil
        Verbose.to_log('Não foi possível capturar o captchacode.')
        retry_
        return nil
      else
        Verbose.to_debug "captchacode reconhecido => #{@captchacode}"
      end

      ## Captura megavar
      self.get_megavar
      if @megavar == nil
        Verbose.to_log('Não foi possível capturar o megavar.')
        retry_
        return nil
      else
        Verbose.to_debug "megavar reconhecido => #{@megavar}"
      end

      ## Captura captcha
      self.get_captcha
      if @captcha == nil or @captcha.size != 4
        Verbose.to_log('Não foi possível capturar o captcha.')
        retry_
        return nil
      else
        Verbose.to_debug "Captcha reconhecido => #{@captcha}"
      end

      ## Requisição POST
      Verbose.to_debug('Enviando requisição de download...')
      hash = {
        "captchacode" => @captchacode,
        "megavar" => @megavar,
        "captcha" => @captcha
      }
      post = HTTPClient.new
      response = post.post(@uri_parsed, hash)
      unless response.header.status_code == 200
        Verbose.to_log "Erro no POST."
        retry_
        return nil
      end
      @body = response.body.content
      # Fim da requisição POST

      if self.captcha_recognized?
        Verbose.to_debug "Captcha está correto."
      else
        Verbose.to_log('ERRO: Captcha não está correto.')
        retry_
        return nil
      end

      ## Captura link do download
      self.get_downloadlink
      if @downloadlink == nil
        Verbose.to_log('Não foi possível capturar o link para download.')
        retry_
        return nil
      end

      begin
        servidor_host = self.recognize_server
        if servidor_host == nil
          if retry_ == Status::OFFLINE
            return nil
          end
        end
      end while servidor_host == nil
      # server = ServerMU.new(servidor_host)

      # Handle download link
      dns = Resolv::DNS.new
      server_ip = dns.getaddress("www#{servidor_host}.megaupload.com").to_s
      @downloadlink.gsub!(/www\d+\.megaupload.com/, server_ip)
      # Fix URL encoding issue
      @downloadlink.gsub!("[", "%5B")
      @downloadlink.gsub!("]", "%5D")
      Verbose.to_log("Link para download: #{@downloadlink}")

      ## Captura tempo de espera
      self.get_countdown
      if @waittime == nil # Testa se identificou o contador
        Verbose.to_log('Não foi possível capturar o contador.')
        retry_
        return nil
      end
      @downloadlink
    rescue Timeout::Error
      Verbose.to_log("Tempo de requisição esgotado. Tentando novamente.")
      retry
    rescue Exception
      @id_status = Status::INTERROMPIDO
      raise
    end
  end
end
