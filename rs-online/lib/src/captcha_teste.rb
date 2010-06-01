require "src/captcha"

url = "http://wwwq42.megaupload.com/gencap.php?3c725d2aa05a0d25.gif"

path = "/tmp/captcha.gif"
Captcha::save(url, path)
ocr = Captcha::recognize(path)
ocr