require "src/captcha"


def regex string, body
  expressao = body.scan(/#{string}/i)[0]
  if expressao == nil
    return false
  else
    return true
  end
end

module Megaupload
  def self.get_captcha body
    expressao = body.scan(/http:\/\/(\S+)\.megaupload.com\/gencap.php?(\S+)\.gif/)[0]
    unless expressao == nil
      url = "http://#{expressao[0]}.megaupload.com/gencap.php?#{expressao[1]}.gif"
      to_debug("URL da imagem: #{url}")
      path = "/tmp/captcha.gif"
      Captcha::save(url, path)
      ocr = Captcha::recognize(path)
      return ocr
    else
      return nil
    end
  end
  def self.get_captchacode body
    search = body.scan(/name=\"captchacode\" value=\"(.+)\">/)[0][0]
    return search
  end
  # => exemplo
  def self.get_megavar body
    search = body.scan(/name=\"megavar\" value=\"(.+)\">/)[0][0]
    return search
  end
  def self.get_size body
    tamanho = body.scan(/font style=.*File size.*>(.+)<\/font/i)[0][0]
    unless tamanho == nil # Testa se identificou o tamanho
      tamanho = tamanho.to_f*1024
      tamanho = tamanho.to_i
    end
    return tamanho
  end
  def self.get_countdown body
    search = body.scan(/count=(\d+);/)[0][0]
    return search.to_i
  end
  def get_filename body
    search = body.scan(/<font style=.*>Filename:<\/font> <font style=.*>(.*)<\/font><br>/)[0][0]
    return search
  end
end
