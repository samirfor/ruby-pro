#!/usr/bin/env ruby

require 'net/http'
require 'socket'
require 'logger'

def ajuda()
  puts "::: Rapidshare V2 :::\n"
  puts ">>> Criado por Samir <samirfor@gmail.com>\n"
  puts "\nUso:\n\n\trapidshare2.rb http://rapidshare.com/files/294960685/ca.3444.by.lol.part1.rar"
  #`zenity --info --title='::: Rapidshare V2 :::' --text="<b>.: Criado por Samir (samirfor@gmail.com)\n</b>\nUso:\n\nrapidshare2.rb http://rapidshare.com/files/294960685/ca.3444.by.lol.part1.rar" --no-wrap`
end

## Captura o link do usuário e trata
## aceitando apenas caracteres válidos
def set_link
  c = 0
  begin
    c += 1
    ajuda
    #link = `zenity --entry --title='Download!!!' --text='Entre com a URL do link (Rapidshare.com) válido' --width=600`
    puts "Entre com a URL do link (Rapidshare.com) válido:"
    link = gets.to_s
    link.chomp! if link == "\n"
  end while link.empty? and c != 3
  exit if c == 3
  link.chomp
end

## Entrada: "www.rapidshare.com"
## Saída: "195.122.131.19"
## Status: OK
def get_ip(host)
  return IPSocket.getaddress(host)
end

## Descrição: faz a troca das URLs
## Status: OK
def trata_body(body, host_ssl, host_rs)
  body.gsub!("http://www.rapidshare.com","http://" + host_rs)
  body.gsub!("http://rapidshare.com","http://" + host_rs)
  body.gsub!("https://ssl.rapidshare.com","https://" + host_ssl)

  ## Detecta servidores e altera para numeros IP
  body.scan(/http:\/\/rs\w{1,}.rapidshare.com/).each do |server|
    host = URI.parse(server).host
    serverIp = get_ip(host)
    body.gsub!(server, "#{'http://' + serverIp}")
  end

  body
end

def contador(tempo)
  begin
    puts "Resta "+tempo.to_s+" segundos."
    tempo -= 1
    sleep(1)
  end while tempo > 0
end

def to_html(body, path_do_arquivo)
  arq = File.open(path_do_arquivo, 'w')
  arq.print(body)
  arq.flush
  arq.close
end

def gerar_html(resposta, path_do_arquivo)
  puts "\nGerando arquivo HTML..."
  to_html(resposta, path_do_arquivo)
  puts "Arquivo criado."
  puts "Abrindo navegador firefox..."
  system('firefox '+path_do_arquivo)
end

def to_log(texto)
  logger = Logger.new('rs.log', 10, 1024000)
  logger.datetime_format = "%d/%m %H:%M:%S"
  logger.info(texto)
  logger.close
  puts texto
end

def falhou(segundos)
  to_log("Tentando novamente em #{segundos} segundos.")
  sleep(segundos)
end

def get_justify(body)
  justify = nil
  justify = body.scan(/<p align=\"justify\">.+<\/p>/)[0]
  if justify != nil
    justify.gsub!("<p align=\"justify\">", "").gsub!("</p>", "")
    to_log(justify)
    return true
  else
    to_log("Download sem mensagem de justificativa. OK!")
    return false
  end
end

def get_no_slot(body)
  str = nil
  str = body.scan(/no more download slots available/)[0]
  if str != nil
    to_log("Não há slots disponíveis no momento.")
    return true
  else
    return false
  end
end

def respaw(body)
  time = nil
  time = body.scan(/try again in about \d+ minutes/)[0]
  if time != nil
    time.gsub!("try again in about ","").gsub!(" minutes","")
    to_log("Respaw de #{time} minutos.")
    sleep(60*time.to_i)
  end
end



#################
#      Main
#################
def main
  if ARGV[0] == nil and $link == nil
    $link = set_link
  else
    $link = ARGV[0]
  end
  to_log("Baixando o link:\n"+$link)
  url = URI.parse($link)
  host_rs = get_ip(url.host)
  host_ssl = get_ip('ssl.rapidshare.com')
  path = url.path
  path_do_arquivo = "#{'/home/'+`whoami`.chomp+'/rapid.html'}"

  begin
    http = Net::HTTP.new(host_rs)
    to_log('Abrindo conexão HTTP...')
    headers, body = http.get(path)
    if headers.code == "200"
      ## Requisitando pagina de download
      to_log('Conexão HTTPOK 200.')

      servidor_host = body.scan(/rs\w{1,}.rapidshare.com/)[0]
      ## Testa se identificou o host
      if servidor_host == nil
        to_log("\nNão foi possível capturar o servidor.")
        to_log("Verifique se a URL está correta.")
        exit
      end
      to_log('Servidor ' + servidor_host + ' identificado.')
      servidor_ip = get_ip(servidor_host)
      body = trata_body(body, host_ssl, host_rs)

      ## Tratando a resposta do POST (1)
      ip_url = URI.parse('http://' + servidor_ip + path)
      to_log('Enviando requisição de download...')
      resposta = Net::HTTP.post_form(ip_url, {'dl.start'=>'Free'})
      resposta = trata_body(resposta.body, host_ssl, host_rs)

      return false if get_no_slot(resposta)
      return false if get_justify(resposta)
      respaw(resposta)

      wait = resposta.scan(/Please try again in \d+ minutes/)[0]
      if wait != nil
        wait.gsub!("Please try again in ","").gsub!(" minutes","")
        to_log("Aguardando #{wait.to_s} minutos.")
        wait = wait.to_i
        sleep(60*wait-10)
        return false
      else
        to_log("Download sem alertas. OK!")
      end
      
      #gerar_html(resposta, path_do_arquivo)
      #to_html(resposta, path_do_arquivo)

      ## Captura tempo de espera
      tempo = resposta.scan(/var c=\d{1,};/)[0]
      if tempo == nil # Testa se identificou o contador
        to_log('Não foi possível capturar o contador.')
        return false
      end
      tempo.gsub!("var c=", "").gsub!(";","")
      to_log('Contador identificado.')
      contador(tempo.to_i+1)
      download = resposta.scan(/dlf.action=\\\'\S+\\/)[0]
      download.gsub!("dlf.action=\\'","").gsub!("\\","")
      to_log("\nLink para download: " + download)

      ## Download com wget
      baixou = system("wget " + download)
      if baixou
        to_log("Download concluido com sucesso.")
      else
        to_log("Download falhou.")
      end
      return baixou
    else
      to_log("#{headers.code} #{headers.message}")
    end
  rescue Timeout::Error
    to_log("Tempo de requisição esgotado. Tentando novamente.")
    retry
  end
end

begin
  resp = main
  falhou(10) if !resp
end while !resp