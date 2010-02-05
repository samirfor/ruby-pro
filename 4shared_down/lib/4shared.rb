#!/usr/bin/env ruby

=begin
    Copyright (C) 2009 Samir C. Costa <samirfor@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end


require 'net/http'
require 'socket'
require 'logger'

def ajuda()
  puts "::: 4Shared V1 :::\n"
  puts ">>> Criado por Samir <samirfor@gmail.com>\n"
  puts "\nUso:\n\n\t$ 4s http://www.4shared.com/get/45726092/faea4549/FM_2008_by_Magropart1.html"
  #  puts "\t$ rs -l caminho_da_lista_de_links [debug]\n"
  #  puts "Para testar apenas:"
  #  puts "\t$ rs -l caminho_da_lista_de_links -t\n"
  #  puts "Para baixar uma lista de links sem testar:"
  #  puts "\t$ rs -l caminho_da_lista_de_links -s\n"
end

# Traduz hostname da URL para ip
# Retorno: String IP
def get_ip(host)
  begin
    return IPSocket.getaddress(host)
  rescue Exception => err
    if host == "4shared.com" or host == "www.4shared.com"
      to_log "Não foi possível resolver host. Setando manualmente"
      return "72.233.72.131"
    end
  end
end

# Traduz hostname da URL para ip
# Retorno: URI
def url_parse(link)
  url = URI.parse(link)
  url.host = get_ip(url.host)
  URI.parse('http://' + url.host + url.path)
end

# Ler os links do arquivo
# Retorno: Array de links
def get_multi_links(arquivo)
  arq = File.open(arquivo, "r")
  links = Array.new
  arq.each_line do |linha|
    if not (linha =~ /#.*/i or linha == "" or linha == nil or linha == "\n")
      links.push(linha.strip)
    end
  end
  arq.close
  links
end

# Contador regressivo
def contador(tempo, mensagem)
  t = Time.utc(0) + tempo
  $stdout.sync = true
  tempo.downto(0) do
    print "\r" + t.strftime(mensagem)
    sleep 1
    t -= 1
  end
  print "\r" + " " * mensagem.length + "\r"
  $stdout.sync = false
  sleep(1)
end

# Gera linhas de log
def to_log(texto)
  logger = Logger.new('4s.log', 10, 1024000)
  logger.datetime_format = "%d/%m %H:%M:%S"
  logger.info(texto)
  logger.close
  #  to_xml(texto)
  #  save_records(texto)
  puts texto
end

def falhou(segundos)
  to_log("Tentando novamente em #{segundos} segundos.")
  contador(segundos, "Falta %S segundos.")
end

## Captura de erros
def error(body)
  str = nil
  str = body.scan(/<h1>(error|erro)<\/h1>/i)[0]
  if str != nil
    error_msg = body.scan(/<.*--.*E.*-->(.+)/i)[0]
    if error_msg != nil
      to_log(error_msg[0] + " Evitando link.")
    else
      to_log("Houve algum erro do rapidshare. Evitando link.")
    end
    return true
  else
    return false
  end
end

def debug(body)
  arq = File.open("4shared.html", "w")
  arq.print(body)
  arq.close
end

def download_sucess(arquivo)
  arq = File.open(arquivo, "r")
  linhas = arq.readlines
  arq.close
  arq = File.open(arquivo, "w")
  para_escrever = Array.new
  linhas.each do |linha|
    if linha.strip == $link
      para_escrever.push("##" + $link)
    else
      para_escrever.push(linha)
    end
  end
  arq.puts para_escrever
  arq.close
end

def testa_link(link)
  to_log("Testando link: " + link)
  if link =~ /http:\/\/\S+\/.+/
    url = URI.parse(link)
  else
    to_log("ERRO: Link #{link} inválido evitado.")
    return false
  end
  host_4s = get_ip(url.host)

  begin
    http = Net::HTTP.new(host_4s)
    http.read_timeout = 15 #segundos
    headers, body = http.get(url.path)
    if headers.code == "200"
      txt = body.scan(/(Uploaded)|(Last downloaded)/i)[0]
      if txt != nil
        to_log "Teste OK!"
        ## Captura tamanho do arquivo
        tamanho = body.scan(/>(\d+) KB<\/td>/i)[0][0]
        if tamanho == nil # Testa se identificou o tamanho
          to_log('Não foi possível capturar o tamanho.')
        else
          tamanho = tamanho.to_i
          to_log("Tamanho #{tamanho} KB ou #{tamanho/1024.0} MB")
          $tamanho_total += tamanho
        end
      end
    else
      to_log("Não foi possível carregar a página.")
      to_log("#{headers.code} #{headers.message}")
    end
    return true
  rescue Timeout::Error
    to_log("Tempo de requisição esgotado. Tentando novamente.")
    retry
  rescue Exception => err
    STDERR.puts err
    to_log err
  rescue Interrupt => err
    STDERR.puts "\nSinal de interrupção recebido"
    to_log("O programa foi encerrado.")
    exit(1)
  rescue
  end
end


## Método para download
def baixar(link)
  if FileTest.exist?("cancelar")
    to_log "Downloads cancelado pelo usuário."
    exit
  end
  to_log("Baixando o link: "+link)
  url = URI.parse(link)
  host_4s = get_ip(url.host)
  #  url.path.gsub!("/file", "/get")

  begin
    http = Net::HTTP.new(host_4s)
    http.read_timeout = 15 #segundos
    ARGV.each do |item|
      to_log('Abrindo conexão HTTP...') if item == "debug"
    end
    headers, body = http.get(url.path)
    if headers.code == "200"
      # Requisitando pagina de download
      ARGV.each do |item|
        if item == "debug"
          to_log('Conexão HTTPOK 200.')
          debug(body)
        end
      end

      servidor_host = body.scan(/dc\w{1,}.4shared.com/i)[0]
      # Testa se identificou o host
      if servidor_host == nil
        to_log("Não foi possível capturar o servidor.")
        to_log("Verifique se a URL está correta. Evitando ...")
        exit(1)
      end
      ARGV.each do |item|
        if item == "debug"
          to_log('Servidor ' + servidor_host + ' identificado.')
        end
      end
      servidor_ip = get_ip(servidor_host)



      ## Mandando requisição POST
      passkey = body.scan(/name=\"pass\" value=\"(.+)\"/)[0][0]
      if passkey == nil # Testa se identificou o password
        to_log "Não foi possível capturar o passkey."
        abort
      end
      to_log('Enviando requisição de download...')
      resposta = Net::HTTP.post_form(url, {'pass'=>"#{passkey}"})
      resposta = resposta.body
      debug resposta

      ## Captura tempo de espera
      tempo = resposta.scan(/var c = (\d+);/)[0]
      if tempo == nil # Testa se identificou o contador
        to_log('Não foi possível capturar o contador.')
        return false
      end
      t = Time.utc(0) + tempo.to_i
      to_log(t.strftime("Contador identificado: %Hh %Mm %Ss."))
      contador(tempo.to_i, "O download iniciará em %Hh %Mm %Ss.")

      
      exit(0)





      

      link = resposta.scan(/a href=\\\'\S+\\/)[0]
      link.gsub!("dlf.action=\\'","").gsub!("\\","")
      uri = url_parse(link)
      ip_host = get_ip(uri.host)
      download = 'http://' + ip_host + uri.path

      to_log("Link para download: #{download}")
      inicio = Time.now
      ## Download com curl
      baixou = system("curl -LO #{download}")
      fim = Time.now
      tempo = Time.local(0) + (fim - inicio)
      str_tempo = tempo.strftime("%Hh %Mm %Ss")
      if baixou
        to_log("Download concluido com sucesso em #{str_tempo}.")
        to_log("Velocidade média foi de #{tamanho.to_i/(fim - inicio)} KB/s.")
      else
        to_log("Download falhou com #{str_tempo} decorridos.")
      end
      to_log("============")
    else
      to_log("Não foi possível carregar a página.")
      to_log("#{headers.code} #{headers.message}")
      baixou = false
    end
    return baixou
  rescue Timeout::Error
    to_log("Tempo de requisição esgotado. Tentando novamente.")
    retry
  rescue Interrupt
    to_log "\nSinal de interrupção recebido"
    to_log "O programa foi encerrado."
    abort
  rescue Exception => err
    STDERR.puts err
    to_log(err)
  end
end

#################
#      Main
#################
def run
  if ARGV[0] == nil
    to_log "Nenhum parâmetro detectado."
    ajuda
    exit(0)
  end

  if FileTest.exist?("4s.log")
    File.delete("4s.log")
  end

  # Lista de links
  if ARGV[0] == "-l"
    to_log("Baixando uma lista de links.")
    links = get_multi_links(ARGV[1])
    $tamanho_total = 0
    if ARGV[2] == "-s"
      to_log ">> Testando os links........"
      links_ok = Array.new
      links.each do |link|
        links_ok.push(link)# if testa_link(link)
      end
      to_log ">> Tamanho total: #{$tamanho_total/1024.0} MB"
      links_ok.each do |link|
        begin
          resp = baixar(link)
          unless resp
            falhou(10)
          else
            download_sucess(ARGV[1])
          end
        end while !resp
      end
    else
      to_log "Você optou não testar os links."
      links.each do |link|
        begin
          resp = baixar(link)
          unless resp
            falhou(10)
          else
            download_sucess(ARGV[1])
          end
        end while !resp
      end
    end

    to_log("Fim da lista.")
    to_log(">>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<")

  else # único link
    link = ARGV[0]
    begin
      resp = baixar(link)
      falhou(10) if !resp
    end while !resp
  end
end

# O main do programa
begin
  ajuda
  run
rescue Interrupt => err
  to_log "\nSinal de interrupção recebido"
  to_log "O programa foi encerrado."
  abort
rescue SystemExit => err
  to_log("SYSEXIT: O programa foi encerrado.")
rescue Exception => err
  to_log err
  abort
end