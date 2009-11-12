#!/usr/bin/env ruby

require 'net/http'
require 'logger'

def to_log(texto)
     logger = Logger.new('testaConexao.log', 10, 1024000)
     logger.datetime_format = "%d/%m %H:%M:%S"
     logger.info(texto)
     logger.close
     puts texto
end

# Cria html
def to_html(texto)
     arq = File.open("login.html", "w" )
     arq.puts(texto)
     arq.flush
     arq.close
end

# Abre navegador
def abrir_navegador
     local = `pwd`.chomp
     user = `whoami`.chomp
     if user == "root"
          cmd = "su samir -c \"firefox file://#{local}/login.html &\"" 
     else
          cmd = "firefox file://#{local}/login.html"
     end
     return system(cmd)
end


##############
# Main
##############
def autentica
     url = URI.parse('http://10.0.0.1/login')

     to_log("Autenticando\tAbrindo conexão com servidor...")
     http = Net::HTTP.new(url.host)
     headers, body = http.get(url.path)
     if headers.code == "200"
          pwd = `pwd`.chomp
          body.gsub!("<head>", "<head>\n<base href=\"http://10.0.0.1\">")
          body.gsub!("document.login.username.focus();", "document.login.username.value = \"samir\";\ndoLogin();")
          to_log("Abrindo navegador para autenticar...")
          to_html(body)
          abrir_navegador
          sleep(2)
          to_log("Autenticação concluída com sucesso!")
     else
          to_log("Falha na autenticação: #{headers.code} #{headers.message}")
          `zenity --error --text='#{headers.code} #{headers.message}'`
     end
end
