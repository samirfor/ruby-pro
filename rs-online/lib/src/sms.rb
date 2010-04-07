require 'net/http'
require 'uri'
require "rubygems"
require "httpclient" # gem install httpclient

# For debug only
def to_html(body)
  arq = File.open("sms.html", "w")
  arq.print(body)
  arq.close
end

class Celular
  attr_accessor :nome, :ddd, :numero

  def initialize nome, ddd, numero
    @nome = nome
    @ddd = ddd
    @numero = numero
  end
end

module Captcha
  # App GOCR is necessary
  def self.recognize(path)
    system("convert #{path} -colorspace Gray #{path}")
    system("convert #{path} -negate #{path}")
    `gocr #{path}`.chomp.delete(" ").strip
  end

  # App WGET is necessary
  def self.save source_url, filename
    system "wget -q \"#{source_url}\" -O #{filename}"
    #system("cp #{filename} #{filename}.bk")
  end
end

module SMS
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

  def self.enviar(texto)
    if texto.size > 115
      raise ArgumentError
    end
    webhost = "http://www.torpedogratis.net"

    begin
        ## Send form by POST
      torpedo = HTTPClient.new webhost
      action = URI.parse "#{webhost}/sms.php"
      remetente = Celular.new("RSOnline", "85", "88016247")
      destinatario = Celular.new("", "85", "87678424")
      form = Hash.new
      form["operadora"] = 'oi'
      form['ddd'] = destinatario.ddd
      form['numero'] = destinatario.numero
      form['dddr'] = remetente.ddd
      form['numeror'] = remetente.numero
      form['nomer'] = remetente.nome
      form["sms"] = texto
      resposta = torpedo.post(action, form)
    
      # Redirect (knowing ID)
      begin
        id = resposta.body.content.scan(/id=(\d+)/)[0][0]
      rescue Exception => e
        puts "Erro ao detectar ID"
        puts e.to_s
        exit
      end
      puts "ID = #{id}"

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
      image = Captcha::save(url, path)
      ocr = Captcha::recognize(path)
      puts "Captcha reconhecido => #{ocr}"

      ## Send form by POST
      action = URI.parse "#{webhost}/send.php?id=#{id}&op=oi"
      form = Hash.new
      form["myid"] = id
      form['cap'] = ocr
      form['numero'] = destinatario.numero
      form['dddr'] = remetente.ddd
      form['numeror'] = remetente.numero
      form['nomer'] = remetente.nome
      form["sms"] = texto
      torpedo = HTTPClient.new webhost
      resposta = torpedo.post(action, form)
    end while ocr.size != 4
    #    puts resposta.body.content

    if resposta.body.content.scan(/enviada/) != []
      return "Mensagem enviada com sucesso."
    elsif resposta.body.content.scan(/alert\(\".+\"\)/) != []
      erro = resposta.body.content.scan(/alert\(\"(.+)\"\)/)[0][0]
      return "Ocorreu um erro no servidor: #{erro}"
    else
      return "Erro desconhecido."
    end
  end
end