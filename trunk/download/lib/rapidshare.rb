#!/usr/bin/env ruby

require 'net/http'
require 'socket'
require 'logger'

def ajuda()
  puts "::: Rapidshare V2 :::\n"
  puts ">>> Criado por Samir <samirfor@gmail.com>\n"
  puts "\nUso:\n\n\t$ rapidshare.rb http://rapidshare.com/files/294960685/ca.3444.by.lol.part1.rar"
  puts "\t$ rapidshare.rb -l caminho_da_lista_de_links"
  #`zenity --info --title='::: Rapidshare V2 :::' --text="<b>.: Criado por Samir (samirfor@gmail.com)\n</b>\nUso:\n\nrapidshare2.rb http://rapidshare.com/files/294960685/ca.3444.by.lol.part1.rar" --no-wrap`
end

def get_multi_links(arquivo)
  arq = File.open(arquivo, "r")
  links = Array.new
  arq.each_line do |linha|
    links.push(linha.chomp)
  end
  arq.close
  links
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
    sleep(60*time.to_i-10)
    return true
  else
    return false
  end
end

def waiting(body)
  wait = body.scan(/Please try again in \d+ minutes/)[0]
  if wait != nil
    wait.gsub!("Please try again in ","").gsub!(" minutes","")
    to_log("Tentando novamente em #{wait.to_s} minutos.")
    sleep(60*wait.to_i-10)
    return true
  else
    return false
  end
end

def simultaneo(body)
  str = nil
  tempo = 2
  str = body.scan(/already downloading a file/)[0]
  if str != nil
    to_log("Ja existe um download corrente.")
    to_log("Tentando novamente em #{tempo.to_s} minutos.")
    sleep(60*tempo-10)
    return true
  else
    return false
  end
end

def atualiza_lista(links, link_baixado)
  arq = File.open("lista", 'w')
  links.each do |link|
    if link == link_baixado
      link = link_baixado.insert(0, "#")
    end
  end
  arq.print(texto)
  arq.flush
  arq.close
end

def baixar(link)
  return true if link =~ /#.+/
  to_log("Baixando o link: "+link)
  if link =~ /http:\/\/\S+\/.+/
    url = URI.parse(link)
  else
    to_log("Link #{link} inválido evitado.")
    return true
  end
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
        to_log("Não foi possível capturar o servidor.")
        to_log("Verifique se a URL está correta.")
        exit
      end
      to_log('Servidor ' + servidor_host + ' identificado.')
      size = body.scan(/\| (\d+) KB/)[0][0]
      to_log("Tamanho do arquivo: "+size+" KB ou "+(size.to_f/1024).to_s+" MB")
      servidor_ip = get_ip(servidor_host)
      body = trata_body(body, host_ssl, host_rs)

      ## Tratando a resposta do POST (1)
      ip_url = URI.parse('http://' + servidor_ip + path)
      to_log('Enviando requisição de download...')
      resposta = Net::HTTP.post_form(ip_url, {'dl.start'=>'Free'})
      resposta = trata_body(resposta.body, host_ssl, host_rs)

      return false if respaw(resposta)
      return false if waiting(resposta)
      return false if get_no_slot(resposta)
      return false if get_justify(resposta)
      return false if simultaneo(resposta)

      #gerar_html(resposta, path_do_arquivo)
      #to_html(resposta, path_do_arquivo)

      ## Captura tempo de espera
      tempo = resposta.scan(/var c=\d{1,};/)[0]
      if tempo == nil # Testa se identificou o contador
        to_log('Não foi possível capturar o contador.')
        return false
      end
      tempo.gsub!("var c=", "").gsub!(";","")
      to_log("Contador identificado: #{tempo}")
      contador(tempo.to_i+1)

      download = resposta.scan(/dlf.action=\\\'\S+\\/)[0]
      download.gsub!("dlf.action=\\'","").gsub!("\\","")
      to_log("Link para download: #{download}")

      ## Download com wget
      baixou = system("wget -c #{download}")
      if baixou
        to_log("Download concluido com sucesso.")
        to_log("============")
      else
        to_log("Download falhou.")
        to_log("============")
      end
    else
      to_log("#{headers.code} #{headers.message}")
    end
    return baixou
  rescue Timeout::Error
    to_log("Tempo de requisição esgotado. Tentando novamente.")
    retry
  end
end

#################
#      Main
#################
def main
  if ARGV[0] == nil
    ajuda
    exit
  else
    if FileTest.exist?("rs.log")
      File.delete("rs.log")
    end
    if ARGV[0] == "-l"
      if FileTest.exist?(ARGV[1])
        to_log("Baixando uma lista de links.")
        links = get_multi_links(ARGV[1])
        links.each do |link|
          next if link == nil or link == ""
          begin
            resp = baixar(link)
            if !resp
              falhou(10)
            else
              atualiza_lista(links, link)
            end
          end while !resp
        end
        to_log("Fim da lista.")
        to_log(">>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<")
      else
        puts "Arquivo não existe."
        exit
      end
    else
      link = ARGV[0]
      begin
        resp = baixar(link)
        falhou(10) if !resp
      end while !resp
    end
  end
end

main