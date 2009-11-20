#!/usr/bin/env ruby

require 'net/http'
require 'socket'
require 'logger'
require 'rapidshare.rb'
#require 'megaupload'

$arquivo_log = "download.log"

def ajuda()
  puts "::: Down [RS][MU] v3 :::\n"
  puts ">>> Criado por Samir <samirfor@gmail.com>\n"
  puts "\nUso:\n\n\t$ download.rb http://rapidshare.com/files/294960685/ca.3444.by.lol.part1.rar"
  puts "\t$ download.rb -l caminho_da_lista_de_links"
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

def url_parse(link)
  url = URI.parse(link)
  url.host = get_ip(url.host)
  URI.parse('http://' + url.host + url.path)
end

def atualiza_lista(arquivo, link_baixado, status)
  links = get_multi_links(arquivo)
  arq = File.open(arquivo, 'w')
  falhados = Array.new
  links.each do |link|
    if (link.chomp == link_baixado)
      if status == "ok"
        link = link_baixado.insert(0, "#")
      elsif status == "evitar"
        falhados.push(link_baixado)
        next
      elsif status == "inexistente"
        link = link_baixado.insert(0, "##")
      end
    end
    arq.print(link+"\n")
  end
  return if falhados.empty?
  falhados.each do |link|
    arq.print(link+"\n")
  end
  arq.flush
  arq.close
end

def get_ip(host)
  return IPSocket.getaddress(host)
end

def contador(tempo)
  begin
    puts "Resta "+tempo.to_s+" segundos."
    tempo -= 1
    sleep(1)
  end while tempo > 0
end

def to_log(texto)
  logger = Logger.new($arquivo_log, 10, 1024000)
  logger.datetime_format = "%d/%m %H:%M:%S"
  logger.info(texto)
  logger.close
  puts texto
end

def falhou(segundos)
  to_log("Tentando novamente em #{segundos} segundos.")
  sleep(segundos)
end

def checkfile_rs(link)
  begin
    Net::HTTP.get_response(url_parse(link)) do |r|
      if r.body.include?("<h1>FILE DOWNLOAD</h1>")
        true
      else
        false
      end
    end
  rescue URI::InvalidURIError
    false
  rescue Timeout::Error
    to_log("Tempo de requisição de checagem esgotado. Tentando novamente.")
    retry
  end
end

def baixar(link)
  return true if link =~ /#.+/
  to_log("Baixando o link: " + link)
  if link =~ /http:\/\/\S+\/.+/
    url = URI.parse(link)
    if url.host =~ /rapidshare/
      if checkfile_rs(link)
        baixar_rs(link)
      else
        to_log("Link inválido evitado.")
        atualiza_lista(ARGV[1], link, "evitar")
      end
    elsif url.host =~ /megaupload/
      baixar_mu(link)
    else
      to_log("Link inválido evitado.")
      atualiza_lista(ARGV[1], link, "evitar")
    end
  else
    to_log("Link inválido.")
    atualiza_lista(ARGV[1], link, "inexistente")
  end
  true
end

#################
#      Main
#################
def main
  if ARGV[0] == nil
    ajuda
    exit
  else
    if FileTest.exist?($arquivo_log)
      File.delete($arquivo_log)
    end
    if ARGV[0] == "-l"
      if FileTest.exist?(ARGV[1])
        to_log("Baixando uma lista de links.")
        # Capturando links do arquivo
        links = get_multi_links(ARGV[1])
        links.each do |link|
          next if link == nil or link == ""
          begin
            resp = baixar(link)
            if !resp
              falhou(10)
            else
              atualiza_lista(ARGV[1], link, "ok")
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


# The main program
begin
  main
rescue Interrupt => err
  STDERR.puts "\nSinal de interrupção recebido"
  to_log("O programa foi encerrado.")
rescue SystemExit => err
  to_log("O programa foi encerrado.")
rescue Exception => err
  STDERR.puts err
  exit(1)
end