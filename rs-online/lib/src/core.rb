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
require 'src/excecoes'
require 'src/twitter'
require 'src/pacote'

# -- Métodos locais

#Usage
def ajuda()
  puts "::: RS-Online Beta :::\n"
  puts ">>> Criado por Samir <samirfor@gmail.com>\n"
  puts ">>> Incrementado por Átila <camurca.home@gmail.com>\n"
  puts "Banco de Dados PostgreSQL é necessário para rodar o programa."
end

## Traduz hostname da URL para ip
## Retorno: String IP
#def get_ip(host)
#  begin
#    return IPSocket.getaddress(host)
#  rescue Exception
#    return "195.122.131.2" if host == "rapidshare.com" or host == "www.rapidshare.com"
#  end
#end

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
    t = Time.local(0) + tempo
    $stdout.sync = true
    tempo.downto(0) do
      print "\r" + t.strftime(mensagem)
      sleep 1
      t -= 1
    end
    print "\r" + " " * mensagem.length + "\r"
    $stdout.sync = false
    sleep(1)
  rescue Exception
    raise
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
  rescue Exception
    raise
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
  minutos = nil
  minutos = body.scan(/try again in about \d+ minutes/i)[0]
  if minutos != nil
    minutos.gsub!("try again in about ","").gsub!(" minutes","")
    to_log("Respaw de #{minutos} minutos.")
    minutos = minutos.to_i
    contador(60*minutos, "Falta #{"%M min e " if minutos >= 1}%S seg.")
    return true
  else
    return false
  end
end

def waiting(body)
  minutos = body.scan(/Please try again in \d+ minutes/i)[0]
  if minutos != nil
    minutos.gsub!("Please try again in ","").gsub!(" minutes","")
    to_log("Tentando novamente em #{minutos.to_s} minutos.")
    minutos = minutos.to_i
    contador(60*minutos.to_i, "Falta #{"%M min e " if minutos >= 1}%S seg.")
    return true
  else
    return false
  end
end

def simultaneo(body)
  str = nil
  minutos = 2
  str = body.scan(/already downloading a file/i)[0]
  if str != nil
    to_log("Ja existe um download corrente.")
    to_log("Tentando novamente em #{minutos} minutos.")
    contador(60*minutos, "Falta #{"%M min e " if minutos >= 1}%S seg.")
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

#def blocked body, link
#  str = nil
#  str = body.scan(/suspected to contain illegal content and has been blocked/i)[0]
#  if str != nil
#    to_log("O link foi bloqueado.")
#    update_status_link(link.id_link, Status::OFFLINE)
#    return true
#  else
#    return false
#  end
#end



def to_html(body)
  arq = File.open("rapid.html", "w")
  arq.print(body)
  arq.close
end

#def testa_link link
#  begin
#    link.link.strip!
#    to_log "Testando link: " + link.link
#    if link.link =~ /http:\/\/\S+\/.+/
#      url = URI.parse link.link
#    else
#      to_log "ERRO: Link inválido evitado."
#      update_status_link link.id_link, Status::OFFLINE
#      return Status::OFFLINE
#    end
#
#    host_rs = get_ip url.host
#    http = Net::HTTP.new host_rs
#    http.read_timeout = 15 #segundos
#    headers, body = http.get url.path
#    unless headers.code == "200"
#      to_log "Não foi possível carregar a página."
#      to_log "#{headers.code} - #{headers.message}"
#      return Status::INTERROMPIDO
#    end
#    # Requisitando pagina de download
#    return Status::OFFLINE if error body, link
#    txt = body.scan /<h1>.*DOWNLOAD.*<\/h1>/i[0]
#    if txt == nil
#      to_log "Há algum problema com o link."
#      update_status_link link.id_link, Status::OFFLINE
#      return Status::OFFLINE
#    end
#    ## Captura tamanho do arquivo
#    tamanho = body.scan /\| (\d+) KB/i[0][0]
#    if tamanho == nil # Testa se identificou o tamanho
#      to_log 'Não foi possível capturar o tamanho.'
#    else
#      tamanho = tamanho.to_i
#      to_log "Tamanho #{tamanho} KB ou #{sprintf "%.2f MB", tamanho/1024.0}"
#      $tamanho_total += tamanho
#      update_status_link_tamanho link.id_link, tamanho, Status::ONLINE
#    end
#    return Status::ONLINE
#  rescue Timeout::Error
#    to_log "Tempo de requisição esgotado. Tentando novamente."
#    retry
#  rescue Interrupt
#    update_status_link link.id_link, Status::INTERROMPIDO
#    interrupt
#  rescue Exception => err
#    update_status_link link.id_link, Status::OFFLINE
#    to_log err
#    retry
#  end
#end

def cancelar?
  if FileTest.exist?("cancelar") or FileTest.exist?("fechar")
    evento = "Downloads cancelado pelo usuário."
    to_log evento
    tweet evento
    exit!(1)
  end
end

# O mesmo que "cancelar?"
def fechar?
  cancelar?
end

# Testa se identificou o host


def run_thread proc
  while $thread.alive?
    sleep 1
  end
  $thread = Thread.new {proc.call}
end

## Método para download no Rapidshare.com
#def download_rapidshare link
#  begin
#    to_log("Baixando o link: #{link.link}")
#    http = Net::HTTP.new link.ip
#    http.read_timeout = 15 #segundos
#    to_debug 'Abrindo conexão HTTP...'
#    headers, body = http.get(link.path)
#    unless headers.code == "200"
#      to_log "Não foi possível carregar a página."
#      to_log "#{headers.code} #{headers.message}"
#      return Status::INTERROMPIDO
#    end
#    # Requisitando pagina de download
#    to_debug 'Conexão HTTPOK 200.'
#
#    return true if error body, link
#    return true if blocked body, link
#
#    servidor_host = reconhecer_servidor
#    if servidor_host == nil
#      return Status::OFFLINE
#    end
#
#    #    # Testa se identificou o host
#    #    if servidor_host == nil
#    #      to_log("Não foi possível capturar o servidor.")
#    #      to_log("Verifique se a URL está correta. Evitando ...")
#    #      exit(1)
#    #    end
#    #    to_debug('Servidor ' + servidor_host + ' identificado.')
#
#    ## Captura tamanho do arquivo
#    expressao = body.scan(/\| (\d+) KB/i)[0][0]
#    if expressao == nil # Testa se identificou o tamanho
#      to_log('Não foi possível capturar o tamanho.')
#      return Status::INTERROMPIDO
#    else
#      link.tamanho = expressao.to_i
#      to_debug("Tamanho #{link.tamanho} KB ou #{sprintf("%.2f MB", link.tamanho/1024.0)}")
#    end
#
#    ## Mandando requisição POST
#    to_debug('Enviando requisição de download...')
#    ip_url = URI.parse('http://' + link.ip + link.path)
#    resposta = Net::HTTP.post_form(ip_url, {'dl.start'=>'Free'})
#    resposta = resposta.body
#
#    return false if lot_of_users(resposta)
#    return false if respaw(resposta)
#    return false if waiting(resposta)
#    return false if get_no_slot(resposta)
#    return false if simultaneo(resposta)
#    return false if get_justify(resposta)
#
#    ## Captura tempo de espera
#    tempo = resposta.scan(/var c=(\d+)/)[0][0]
#    if tempo == nil # Testa se identificou o contador
#      to_log('Não foi possível capturar o contador.')
#      return false
#    end
#
#    t = Time.local(0) + tempo.to_i
#    to_debug(t.strftime("Contador identificado: %Hh %Mm %Ss."))
#    contador(tempo.to_i, "O download iniciará em %Hh %Mm %Ss.")
#
#    link = resposta.scan(/dlf.action=\\\'\S+\\/)[0]
#    link.gsub!("dlf.action=\\'","").gsub!("\\","")
#    uri = url_parse(link)
#    ip_host = get_ip(uri.host)
#    download = 'http://' + ip_host + uri.path
#
#    to_log("Baixando: #{download}")
#    inicio = Time.now
#    ## Download com curl
#    baixou = system("curl -LO #{download}")
#    fim = Time.now
#    tempo = Time.local(0) + (fim - inicio)
#    str_tempo = tempo.strftime("%Hh %Mm %Ss")
#    if baixou
#      to_log("Download concluido com sucesso em #{str_tempo}.")
#      to_log("Velocidade média foi de #{sprintf("%.2f KB/s", link.tamanho.to_i/(fim - inicio))}.")
#    else
#      to_log("Download falhou com #{str_tempo} decorridos.")
#    end
#
#    return baixou
#  rescue Timeout::Error
#    to_log("Tempo de requisição esgotado. Tentando novamente.")
#    retry
#  rescue Interrupt
#    update_status_link(link.id_link, Status::INTERROMPIDO)
#    interrupt
#  rescue Exception => err
#    to_log err
#    update_status_link(link.id_link, Status::INTERROMPIDO)
#    return false
#  end
#end

#################
#      Main
#################
def run
  begin
    begin
      cancelar?
      ## Select pacote
      pacote = select_pacote_pendente
      if pacote == nil
        evento = "Não há pacotes para download."
        to_log evento
        tweet evento
        exit!(1)
      end
      #      nome_pacote = select_nome_pacote id_pacote
      links_before_test = select_lista_links pacote.id_pacote
      if links_before_test == nil
        to_log "Não foi possível selecionar a lista de links."
        exit!(1)
      end
      ## Fim do Select pacote

      ## Inicio do teste
      pacote.tamanho = 0
      to_log "Testando os links..."
      links_online = Array.new
      links_before_test.each do |link|
        cancelar?
        case link.test
        when Status::ONLINE
          link.id_status = Status::ONLINE
          links_online.push link
        when Status::OFFLINE
          link.id_status = Status::OFFLINE
        when Status::INTERROMPIDO
          link.id_status = Status::INTERROMPIDO
        end
        link.update_db
      end
      ## Fim do teste

      ## Informações do teste
      update_tamanho_pacote(pacote.id_pacote, pacote.tamanho)
      to_log "Tamanho total: #{sprintf("%.2f MB", pacote.tamanho/1024.0)}"
      run_thread Proc.new {
        tweet "Iniciado download do pacote #{pacote.nome} (#{sprintf("%.2f MB", pacote.tamanho/1024.0)})"
      }
      ## Fim Informações do teste

      ## Inicio Download do Pacote
      pacote.data_inicio = Time.now # Marca quando o pacote iniciou download
      links_online.each do |link|
        cancelar?
        begin
          result = link.download
        end while result == Status::TENTANDO
      end
      pacote.data_fim = Time.now
      ## Fim Download do Pacote

      ## Informações do download
      duracao = Time.local(0) + (pacote.data_fim - pacote.data_inicio)
      evento = "Concluido o download do pacote #{pacote.nome}"
      evento += " em #{duracao.strftime("%Hh %Mm %Ss")} | "
      evento += "V. media = #{sprintf("%.2f KB/s", pacote.tamanho/(pacote.data_fim - pacote.data_inicio))}"
      to_log evento
      run_thread Proc.new {
        tweet evento
      }
      if select_remaining_links(pacote.id_pacote) == 0
        pacote.data_fim = Time.now.strftime("%d/%m/%Y %H:%M:%S")
      else
        pacote.problema = true
        run_thread Proc.new {
          tweet "Pacote #{pacote.nome} está problema."
        }
      end
      pacote.update_db
      ## Fim Informações do download
    rescue Interrupt
      raise
    rescue Exception
      raise
    end
  end while pacote != nil
  evento = 'Fim do(s) download(s). Have a nice day!'
  to_log evento
  tweet evento
end

def singleton?
  fullpath = "/home/#{`whoami`.chomp}/rs-online.pid"
  unless FileTest.exist? fullpath
    return true
  end
  arq = File.open(fullpath, "r")
  pid = arq.readline
  arq.close
  ps = `ps -p #{pid} -o command=`.chomp
  if ps =~ /rs-online/i
    return false
  else
    return true
  end
end

# O main do programa
begin
  ajuda
  if singleton?
    # Guardando o numero do pid
    arq = File.open("/home/#{`whoami`.chomp}/rs-online.pid", "w")
    arq.print Process.pid
    arq.close
    $thread = Thread.new {}
    run
  else
    puts 'Há outro processo rodando nesta máquina.'
    exit!
  end
rescue Interrupt
  interrupt
rescue SystemExit => err
  evento = "O programa foi encerrado."
  to_log evento
  tweet evento
  exit!
rescue Exception => err
  to_log err
  abort
end
