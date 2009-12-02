#!/usr/bin/env ruby

require 'net/http'
require 'socket'
require 'logger'

def ajuda()
  puts "::: Rapidshare V3 :::\n"
  puts ">>> Criado por Samir <samirfor@gmail.com>\n"
  puts "\nUso:\n\n\t$ rapidshare3.rb http://rapidshare.com/files/294960685/ca.3444.by.lol.part1.rar"
  puts "\t$ rapidshare3.rb -l caminho_da_lista_de_links"
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
    links.push(linha.chomp)
  end
  arq.close
  links
end

# Contador regressivo
def contador(tempo, mensagem)
  t = Time.utc(0) + tempo
  to_log(t.strftime("Contador identificado: %Hh %Mm %Ss."))
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
  puts texto
end

def falhou(segundos)
  to_log("Tentando novamente em #{segundos} segundos.")
  sleep(segundos)
end

## Captura de erros
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

def lot_of_users(body)
  res = body.scan(/Currently a lot of users are downloading files/)[0]
  if res != nil
    to_log("Atualmente muitos usuários estão baixando arquivos.")
    to_log("Tentando novamente em 2 minutos.")
    sleep(60*2-10)
    return true
  else
    return false
  end
end


## Método para download
def baixar
  return true if $link =~ /#.+/
  to_log("Baixando o link: "+$link)
  if $link =~ /http:\/\/\S+\/.+/
    url = URI.parse($link)
  else
    to_log("Link #{$link} inválido evitado.")
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
      # Requisitando pagina de download
      to_log('Conexão HTTPOK 200.')
      servidor_host = body.scan(/rs\w{1,}.rapidshare.com/)[0]
      # Testa se identificou o host
      if servidor_host == nil
        to_log("Não foi possível capturar o servidor.")
        to_log("Verifique se a URL está correta. Evitando ...")
        return true
      end
      to_log('Servidor ' + servidor_host + ' identificado.')
      servidor_ip = get_ip(servidor_host)

      ## Mandando requisição POST
      ip_url = URI.parse('http://' + servidor_ip + path)
      to_log('Enviando requisição de download...')
      resposta = Net::HTTP.post_form(ip_url, {'dl.start'=>'Free'})
      resposta = resposta.body

      return false if lot_of_users(resposta)
      return false if respaw(resposta)
      return false if waiting(resposta)
      return false if get_no_slot(resposta)
      return false if simultaneo(resposta)
      return false if get_justify(resposta)

      ## Captura tempo de espera
      tempo = resposta.scan(/var c=\d{1,};/)[0]
      if tempo == nil # Testa se identificou o contador
        to_log('Não foi possível capturar o contador.')
        return false
      end
      tempo.gsub!("var c=", "").gsub!(";","")

      puts "Link para download: #{download}"

      contador(tempo.to_i, "O download iniciará em %Hh %Mm %Ss.")

      download = resposta.scan(/dlf.action=\\\'\S+\\/)[0]
      download.gsub!("dlf.action=\\'","").gsub!("\\","")
      download = download.extract(download)

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
    # Lista de links
    if ARGV[0] == "-l"
      if FileTest.exist?(ARGV[1])
        to_log("Baixando uma lista de links.")
        links = get_multi_links(ARGV[1])
        links.each do |link|
          next if link == nil or link == ""
          $link = link
          begin
            resp = baixar
            falhou(10) if !resp
          end while !resp
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