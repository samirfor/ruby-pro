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
require 'rexml/document'
include REXML

def ajuda()
  puts "::: Rapidshare V3 :::\n"
  puts ">>> Criado por Samir <samirfor@gmail.com>\n"
  puts "\nUso:\n\n\t$ rs http://rapidshare.com/files/294960685/ca.3444.by.lol.part1.rar"
  puts "\t$ rs -l caminho_da_lista_de_links [debug]\n"
  puts "Para testar apenas:"
  puts "\t$ rs -l caminho_da_lista_de_links -t\n"
  puts "Para baixar uma lista de links sem testar:"
  puts "\t$ rs -l caminho_da_lista_de_links -s\n"
end

# Traduz hostname da URL para ip
# Retorno: String IP
def get_ip(host)
  begin
    return IPSocket.getaddress(host)
  rescue Exception
    case host
    when "rapidshare.com"
      return "195.122.131.2"
      break
    when "www.rapidshare.com"
      return "195.122.131.2"
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
      links.push(linha.chomp)
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
  logger = Logger.new('rs.log', 10, 1024000)
  logger.datetime_format = "%d/%m %H:%M:%S"
  logger.info(texto)
  logger.close
  to_xml(texto)
  puts texto
end

def to_xml(texto)
  doc = Document.new 
  linha = Element.new "historico"
  doc.add_element linha
  #linha = Element.new "td"
  # formatar hora
  tempo = Time.new
  linha.attributes["data"] = tempo.strftime("%Y/%m/%d %H:%M:%S")
  # processo
  processo = Process.pid
  linha.attributes["processo"] = processo.to_s
  # historico
  linha.attributes["mensagem"] = texto
  doc.root.add_element linha
  doc.write(File.open("rs.log.xml", "a"), 1)
end

def falhou(segundos)
  to_log("Tentando novamente em #{segundos} segundos.")
  contador(segundos, "Falta %S segundos.")
end

## Captura de erros
def get_justify(body)
  justify = nil
  justify = body.scan(/<p align=\"justify\">.+<\/p>/i)[0]
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

def server_maintenance(body)
  str = nil
  str = body.scan(/The server \d+.rapidshare.com is momentarily not available/i)[0]
  if str != nil
    server = str.scan(/\d+/)[0]
    to_log("O servidor do rapidshare #{server} está em manutenção. Evitando")
    return true
  else
    return false
  end
end

def respaw(body)
  time = nil
  time = body.scan(/try again in about \d+ minutes/i)[0]
  if time != nil
    time.gsub!("try again in about ","").gsub!(" minutes","")
    to_log("Respaw de #{time} minutos.")
    contador(60*time.to_i, "Falta %M min e %S seg.")
    return true
  else
    return false
  end
end

def waiting(body)
  wait = body.scan(/Please try again in \d+ minutes/i)[0]
  if wait != nil
    wait.gsub!("Please try again in ","").gsub!(" minutes","")
    to_log("Tentando novamente em #{wait.to_s} minutos.")
    contador(60*wait.to_i, "Falta %M min e %S seg.")
    return true
  else
    return false
  end
end

def simultaneo(body)
  str = nil
  tempo = 2
  str = body.scan(/already downloading a file/i)[0]
  if str != nil
    to_log("Ja existe um download corrente.")
    to_log("Tentando novamente em #{tempo.to_s} minutos.")
    contador(60*tempo, "Falta %M min e %S seg.")
    return true
  else
    return false
  end
end

def lot_of_users(body)
  res = body.scan(/Currently a lot of users are downloading files/i)[0]
  if res != nil
    to_log("Atualmente muitos usuários estão baixando arquivos.")
    to_log("Tentando novamente em 2 minutos.")
    contador(60*2, "Falta %M min e %S seg.")
    return true
  else
    return false
  end
end

def debug(body)
  arq = File.open("rapid.html", "w")
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
    if linha.chomp == $link
      para_escrever.push("##" + $link)
    else
      para_escrever.push(linha)
    end
  end
  arq.puts para_escrever
  arq.close
end

def estatistica()

end

def testa_link(link)
  to_log("Testando link: " + link)
  if link =~ /http:\/\/\S+\/.+/
    url = URI.parse(link)
  else
    to_log("ERRO: Link #{link} inválido evitado.")
    return false
  end
  host_rs = get_ip(url.host)

  begin
    http = Net::HTTP.new(host_rs)
    http.read_timeout = 15 #segundos
    headers, body = http.get(url.path)
    if headers.code == "200"
      # Requisitando pagina de download
      return false if error(body)
      txt = body.scan(/<h1>.*DOWNLOAD.*<\/h1>/i)[0]
      if txt != nil
        to_log "Teste OK!"
      else
        to_log "Algum problema com o link."
        return false
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
def baixar
  if FileTest.exist?("cancelar")
    to_log "Downloads cancelado pelo usuário."
    exit
  end
  to_log("Baixando o link: "+$link)
  if $link =~ /http:\/\/\S+\/.+/
    url = URI.parse($link)
  else
    to_log("ERRO: Link #{$link} inválido evitado.")
    return true
  end
  host_rs = get_ip(url.host)

  begin
    http = Net::HTTP.new(host_rs)
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
      return true if error(body)

      servidor_host = body.scan(/rs\w{1,}.rapidshare.com/i)[0]
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

      ## Captura tamanho do arquivo
      tamanho = body.scan(/\| (\d+) KB/i)[0][0]
      if tamanho == nil # Testa se identificou o tamanho
        to_log('Não foi possível capturar o tamanho.')
      else
        tamanho = tamanho.to_i
        to_log("Tamanho #{tamanho} KB ou #{tamanho/1024.0} MB")
      end

      ## Mandando requisição POST
      to_log('Enviando requisição de download...')
      ip_url = URI.parse('http://' + servidor_ip + url.path)
      resposta = Net::HTTP.post_form(ip_url, {'dl.start'=>'Free'})
      resposta = resposta.body

      return false if lot_of_users(resposta)
      return false if respaw(resposta)
      return false if waiting(resposta)
      return false if get_no_slot(resposta)
      return false if simultaneo(resposta)
      return false if get_justify(resposta)

      ## Captura tempo de espera
      tempo = resposta.scan(/var c=(\d+)/)[0][0]
      if tempo == nil # Testa se identificou o contador
        to_log('Não foi possível capturar o contador.')
        return false
      end

      t = Time.utc(0) + tempo.to_i
      to_log(t.strftime("Contador identificado: %Hh %Mm %Ss."))
      contador(tempo.to_i, "O download iniciará em %Hh %Mm %Ss.")

      link = resposta.scan(/dlf.action=\\\'\S+\\/)[0]
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
  rescue Exception => err
    STDERR.puts err
    to_log(err)
  rescue
  end
end

#################
#      Main
#################
def run
  if ARGV[0] == nil
    ajuda
    exit
  else
    if FileTest.exist?("rs.log")
      File.delete("rs.log")
    end
    #    # arquivo xml
    #    if FileTest.exist?("rs.log.xml")
    #      File.delete("rs.log.xml")
    #    end

    #    doc = Document.new
    #    xmldecl = XMLDecl.new("1.0", "UTF-8", "no")
    #    doc.add xmldecl
    #    doc.write(File.open("rs.log.xml", "w"), 1)

    # Lista de links
    if ARGV[0] == "-l"
      if FileTest.exist?(ARGV[1])
        if ARGV[2] == "-t"
          puts ">> Apenas testando os links:"
          links = get_multi_links(ARGV[1])
          puts "Testando #{links.size} links."
          count = 0
          links.each do |link|
            count += 1 if not testa_link(link)
          end
          if count == 0
            puts "Não há links com problema."
          else
            puts "Há #{count} links com problema."
          end
          exit
        end
        to_log("Baixando uma lista de links.")
        links = get_multi_links(ARGV[1])
        unless ARGV[2] == "-s"
          to_log ">> Testando os links........"
          links_ok = Array.new
          links.each do |link|
            links_ok.push(link) if testa_link(link)
          end
          links_ok.each do |link|
            $link = link
            begin
              resp = baixar
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
            $link = link
            begin
              resp = baixar
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
      else
        to_log "Arquivo não existe."
        exit
      end
      # Link unico
    else
      $link = ARGV[0]
      begin
        resp = baixar
        falhou(10) if !resp
      end while !resp
    end
  end
end

# O main do programa
begin
  run
rescue Interrupt => err
  STDERR.puts "\nSinal de interrupção recebido"
  to_log("O programa foi encerrado.")
rescue SystemExit => err
  to_log("O programa foi encerrado.")
rescue Exception => err
  STDERR.puts err
  exit(1)
end
