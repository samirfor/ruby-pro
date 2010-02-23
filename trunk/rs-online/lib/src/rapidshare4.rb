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

# -- Diretórios de instalação
$:.push "/home/#{`whoami`.chomp}/NetBeansProjects/rs-online/lib"
$:.push "/home/#{`whoami`.chomp}/NetBeansProjects/trunk/rs-online/lib"

# -- Bibliotecas, classes e módulos
require 'net/http'
require 'socket'
require 'dbi'
require 'src/link'
require 'src/database'
require 'src/status'
require 'src/prioridade'

# -- Métodos locais

#Usage
def ajuda()
  puts "::: Rapidshare V4 :::\n"
  puts ">>> Criado por Samir <samirfor@gmail.com>\n"
  puts "Banco de Dados PostgreSQL necessário para rodar o programa."
end

# Traduz hostname da URL para ip
# Retorno: String IP
def get_ip(host)
  begin
    return IPSocket.getaddress(host)
  rescue Exception
    return "195.122.131.2" if host == "rapidshare.com" or host == "www.rapidshare.com"
  end
end

# Traduz hostname da URL para ip
# Retorno: URI
def url_parse(link)
  url = URI.parse(link)
  url.host = get_ip(url.host)
  URI.parse('http://' + url.host + url.path)
end

# Contador regressivo
def contador(tempo, mensagem)
  begin
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
  rescue Interrupt
    to_log "\nSinal de interrupção recebido"
    to_log "O programa foi encerrado."
    exit!(1)
  end
end

# Gera linhas de log
def to_log texto
  save_historico texto
  puts texto
end

# Gera linhas de log debug
def to_debug texto
  ARGV.each do |arg|
    if arg == "debug"
      save_historico texto
      puts texto
    end
  end
end

def falhou(segundos)
  begin
    to_log("Tentando novamente em #{segundos} segundos.")
    contador(segundos, "Falta %S segundos.")
  rescue Interrupt
    to_log "\nSinal de interrupção recebido"
    to_log "O programa foi encerrado."
    exit!(1)
  end
end

## -- Captura de erros

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

def error(body, link)
  str = nil
  str = body.scan(/<h1>(error|erro)<\/h1>/i)[0]
  if str != nil
    error_msg = body.scan(/<.*--.*E.*-->(.+)/i)[0]
    if error_msg != nil
      to_log(error_msg[0] + " Evitando link.")
    else
      to_log("Houve algum erro do rapidshare. Evitando link.")
    end
    update_status_link(link.id_link, Status::OFFLINE)
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

def get_justify body
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

def blocked body, link
  str = nil
  str = body.scan(/suspected to contain illegal content and has been blocked/i)[0]
  if str != nil
    to_log("O link foi bloqueado.")
    update_status_link(link.id_link, Status::OFFLINE)
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

def to_html(body)
  arq = File.open("rapid.html", "w")
  arq.print(body)
  arq.close
end

def testa_link(link)
  begin
    cancelar?
  
    link.link.strip!
    to_log("Testando link: " + link.link)
    if link.link =~ /http:\/\/\S+\/.+/
      url = URI.parse(link.link)
    else
      to_log("ERRO: Link inválido evitado.")
      update_status_link(link.id_link, Status::OFFLINE)
    end
    host_rs = get_ip(url.host)

    http = Net::HTTP.new(host_rs)
    http.read_timeout = 15 #segundos
    headers, body = http.get(url.path)
    if headers.code == "200"
      # Requisitando pagina de download
      return false if error(body, link)
      txt = body.scan(/<h1>.*DOWNLOAD.*<\/h1>/i)[0]
      if txt != nil
        to_log "Teste OK!"
        ## Captura tamanho do arquivo
        tamanho = body.scan(/\| (\d+) KB/i)[0][0]
        if tamanho == nil # Testa se identificou o tamanho
          to_log('Não foi possível capturar o tamanho.')
        else
          tamanho = tamanho.to_i
          to_log("Tamanho #{tamanho} KB ou #{sprintf("%.2f MB", tamanho/1024.0)}")
          $tamanho_total += tamanho
          update_status_link_tamanho(link.id_link, tamanho, Status::ONLINE)
        end
      else
        to_log "Algum problema com o link."
        update_status_link(link.id_link, Status::OFFLINE)
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
  rescue Interrupt
    update_status_link(link.id_link, Status::INTERROMPIDO)
    to_log "\nSinal de interrupção recebido"
    to_log "O programa foi encerrado."
    exit!(1)
  rescue Exception => err
    update_status_link(link.id_link, Status::OFFLINE)
    to_log err
    retry
  end
end

def cancelar?
  if FileTest.exist?("cancelar") or FileTest.exist?("fechar")
    to_log "Downloads cancelado pelo usuário."
    exit!(1)
  end
end

# O mesmo que "cancelar?"
def fechar?
  cancelar?
end


## Método para download
def baixar(link)
  begin
    cancelar?

    to_log("Baixando o link: #{link}")
    if link =~ /http:\/\/\S+\/.+/
      url = URI.parse(link)
    else
      to_log("ERRO: Link #{link} inválido evitado.")
      update_status_link(link.id_link, Status::OFFLINE)
    end
    host_rs = get_ip(url.host)

    http = Net::HTTP.new(host_rs)
    http.read_timeout = 15 #segundos
    to_debug('Abrindo conexão HTTP...')
    headers, body = http.get(url.path)
    if headers.code == "200"
      # Requisitando pagina de download
      to_debug('Conexão HTTPOK 200.')

      return true if error body, link
      return true if blocked body, link

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
        return false
      else
        tamanho = tamanho.to_i
        to_debug("Tamanho #{tamanho} KB ou #{sprintf("%.2f MB", tamanho/1024.0)}")
      end

      ## Mandando requisição POST
      to_debug('Enviando requisição de download...')
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
      to_debug(t.strftime("Contador identificado: %Hh %Mm %Ss."))
      contador(tempo.to_i, "O download iniciará em %Hh %Mm %Ss.")

      link = resposta.scan(/dlf.action=\\\'\S+\\/)[0]
      link.gsub!("dlf.action=\\'","").gsub!("\\","")
      uri = url_parse(link)
      ip_host = get_ip(uri.host)
      download = 'http://' + ip_host + uri.path

      to_log("Baixando: #{download}")
      inicio = Time.now
      ## Download com curl
      baixou = system("curl -LO #{download}")
      fim = Time.now
      tempo = Time.local(0) + (fim - inicio)
      str_tempo = tempo.strftime("%Hh %Mm %Ss")
      if baixou
        to_log("Download concluido com sucesso em #{str_tempo}.")
        to_log("Velocidade média foi de #{sprintf("%.2f KB/s", tamanho.to_i/(fim - inicio))}.")
      else
        to_log("Download falhou com #{str_tempo} decorridos.")
      end
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
    update_status_link(link.id_link, Status::INTERROMPIDO)
    to_log "\nSinal de interrupção recebido"
    to_log "O programa foi encerrado."
    exit!(1)
  rescue Exception => err
    to_log err
    update_status_link(link.id_link, Status::INTERROMPIDO)
    return false
  end
end

#################
#      Main
#################
def run
  begin
    begin
      $tamanho_total = 0

      id_pacote = select_pacote_pendente
      if id_pacote == nil
        to_log "Não há pacotes resgistrados para download."
        exit!(1)
      end
      links_before_test = select_lista_links(id_pacote)

      to_log "Testando os links........"
      update_tamanho_pacote(id_pacote, 0) # zera o tamanho do pacote
      links_online = Array.new
      links_before_test.each do |link|
        if testa_link(link)
          links_online.push(link)
        else
          update_status_link(link.id_link, Status::OFFLINE)
        end
      end

      update_tamanho_pacote(id_pacote, $tamanho_total)
      to_log "Tamanho total: #{sprintf("%.2f MB", $tamanho_total/1024.0)} MB"
      links_online.each do |link|
        begin
          update_status_link(link.id_link, Status::BAIXANDO)
          update_data_inicio_link(link.id_link, Time.now.strftime("%d/%m/%Y %H:%M:%S"))
          resp = baixar(link.link.strip)
          unless resp
            falhou(10)
          else
            update_link_completado(link.id_link, Time.now.strftime("%d/%m/%Y %H:%M:%S"), Status::BAIXADO)
          end
        end while !resp
      end
      to_log("Fim do pacote.")
      if select_status_links(id_pacote) == 0
        update_pacote_completado(Time.now.strftime("%d/%m/%Y %H:%M:%S"), id_pacote)
      else
        update_pacote_problema(id_pacote)
      end
    rescue Interrupt
      to_log "\nSinal de interrupção recebido"
      to_log "O programa foi encerrado."
      exit!(1)
    rescue Exception => err
      to_debug err
      retry
    end
  end while id_pacote != nil
  to_log("Fim do(s) download(s).")
end

def singleton?
  ps = `ps -ef | grep rs-online`.to_a
  return false if ps.size >= 4
  return true
end

# O main do programa
begin
  ajuda
  if singleton?
    run
  else
    to_log 'Há outro processo "rs-online" rodando nesta máquina.'
    abort
  end
rescue Interrupt
  to_log "\nSinal de interrupção recebido"
  to_log "O programa foi encerrado."
  exit!(1)
rescue SystemExit => err
  to_log("O programa foi encerrado.")
  exit!
rescue Exception => err
  to_log err
  abort
end
