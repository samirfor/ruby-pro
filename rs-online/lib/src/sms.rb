# For debug only
def to_html(body)
  arq = File.open("sms.html", "w")
  arq.print(body)
  arq.close
end

module SMS
  require 'net/http'
  require 'uri'
  require "rubygems"
  require "httpclient" # gem install httpclient
  require "src/captcha"
  require "src/celular"
  
  def self.trata_caracteres_invalidos texto
    texto.gsub!("ç", "c")
    texto.gsub!("ã", "a")
    texto.gsub!("õ", "o")
    texto.gsub!("á", "a")
    texto.gsub!("é", "e")
    texto.gsub!("í", "i")
    texto.gsub!("ó", "o")
    texto.gsub!("ú", "u")
    texto.gsub!("â", "a")
    texto.gsub!("ê", "e")
    texto.gsub!("ô", "o")
    texto.gsub!("ü", "u")
    texto.gsub!("_", " ")
    texto
  end

  def self.enviar(msg, *celulares)
    if msg.size > 115
      raise ArgumentError
    end
    webhost = "http://www.torpedogratis.net"

    raise ArgumentError unless celulares.is_a?(Array)

    send_erro = false
    celulares.each do |celular|
      begin
        begin
          ## Send form by POST
          torpedo = HTTPClient.new webhost
          action = URI.parse "#{webhost}/sms.php"
          remetente = Celular.new(85, 88009999)
          destinatario = celular
          form = Hash.new
          form["operadora"] = 'oi'
          form['ddd'] = destinatario.ddd.to_s
          form['numero'] = destinatario.numero.to_s
          form['dddr'] = remetente.ddd.to_s
          form['numeror'] = remetente.numero.to_s
          form['nomer'] = "RSOnline"
          form["sms"] = msg
          resposta = torpedo.post(action, form)
    
          # Redirect (knowing ID)
          begin
            id = resposta.body.content.scan(/id=(\d+)/)[0][0]
          rescue Exception => e
            puts "SMS: Erro ao detectar ID: #{e}"
            raise
          end
          puts "SMS: ID = #{id}"

          #    begin
          action = URI.parse "#{webhost}/envia.php"
          query = {
            "id" => "#{id}",
            "op"=>"oi"
          }
          torpedo = HTTPClient.new webhost
          resposta = torpedo.get(action, query)

          # Redirect
          action = URI.parse "#{webhost}/confirma.php"
          query = {
            "id" => "#{id}",
            "op"=>"oi"
          }
          torpedo = HTTPClient.new webhost
          resposta = torpedo.get(action, query)
    
          # Knowing id_session
          begin
            id_session_image = resposta.body.content.scan(/cap\/oi\/#{id}\.jpg.a=(\d+)/)[0][0]
          rescue Exception => e
            puts "Erro ao detectar captcha code"
            puts e.to_s
            exit
          end
          puts "ID da sessão da imagem = #{id_session_image}"
    
          # OCR
          url = "#{webhost}/cap/oi/#{id}.jpg?a=#{id_session_image}"
          puts "URL captcha = #{url}"
          path = "/tmp/captcha.png"
          false unless Captcha::save(url, path)
          ocr = Captcha::TorpedoGratis.recognize(path)
          puts "Captcha reconhecido => #{ocr}"

          ## Send form by POST
          action = URI.parse "#{webhost}/send.php?id=#{id}&op=oi"
          form = Hash.new
          form["myid"] = id
          form['cap'] = ocr
          form['numero'] = destinatario.numero.to_s
          form['dddr'] = remetente.ddd.to_s
          form['numeror'] = remetente.numero.to_s
          form['nomer'] = "RSOnline"
          form["sms"] = msg
          torpedo = HTTPClient.new webhost
          resposta = torpedo.post(action, form)
        end while ocr.size != 4

        if resposta.body.content.scan(/enviada/) != []
          puts "Mensagem enviada com sucesso."
        elsif resposta.body.content.scan(/alert\(\".+\"\)/) != []
          erro = resposta.body.content.scan(/alert\(\"(.+)\"\)/)[0][0]
          puts "Ocorreu um erro no servidor: #{erro}"
          send_erro = true
        else
          puts "Erro desconhecido."
          send_erro = true
          raise
        end
        if send_erro
          puts "Houve(ram) erro(s) durante a emissão de SMS(s)."
          false
        else
          true
        end
      rescue
        retry
      end
    end # def
  end
end