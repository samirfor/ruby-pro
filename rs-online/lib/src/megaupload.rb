require "src/captcha"
require "resolv"

class Megaupload

  attr_reader :body

  def initialize body
    @body = body
  end

  def get_captcha
    expressao = @body.scan(/http:\/\/(\S+)\.megaupload.com\/gencap.php\?(\S+)\.gif/)[0]
    unless expressao == nil
      url = "http://#{expressao[0]}.megaupload.com/gencap.php?#{expressao[1]}.gif"
      to_debug("URL da imagem: #{url}")
      dns = Resolv::DNS.new
      expressao[0] = dns.getaddress("#{expressao[0]}.megaupload.com").to_s
      url = "http://#{expressao[0]}/gencap.php?#{expressao[1]}.gif"
      to_debug("URL da imagem: #{url}")
      path = "/tmp/captcha.gif"
      Captcha::save(url, path)
      ocr = Captcha::recognize(path)
      return ocr
    else
      return nil
    end
  end
  def get_captchacode
    search = @body.scan(/name=\"captchacode\" value=\"(.+)\">/)[0][0]
    return search
  end
  # => exemplo
  def get_megavar
    search = @body.scan(/name=\"megavar\" value=\"(.+)\">/)[0][0]
    return search
  end
  def get_size
    tamanho = @body.scan(/font style=.*File size.*>(.+)<\/font/i)[0][0]
    unless tamanho == nil # Testa se identificou o tamanho
      tamanho = tamanho.to_f*1024
      tamanho = tamanho.to_i
    end
    return tamanho
  end
  def get_countdown
    search = @body.scan(/count=(\d+);/)[0][0]
    unless search == nil
      return search.to_i
    end
    nil
  end
  def get_filename
    search = @body.scan(/<font style=.*>Filename:<\/font> <font style=.*>(.*)<\/font><br>/)[0][0]
    puts "link: #{search}"
    return search
  end

  def get_downloadlink
    begin
      search = @body.scan(/downloadlink.*href=\"(.*)\" onclick/i)[0][0]
      return search
    rescue
      return nil
    end
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
  def reconhecer_servidor
    servidor_host = @body.scan(/http:\/\/www(\d+)\.megaupload\.com\/files/i)[0][0]
    if servidor_host == nil
      to_log("Não foi possível reconhecer o servidor.")
      to_log("Verifique se a URL está correta. Evitando ...")
      return nil
    end
    to_debug("Servidor www#{servidor_host}.megaupload.com identificado.")
    servidor_host.to_i
  end
end
