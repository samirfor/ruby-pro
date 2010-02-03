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

# Link Test
# http://rapidshare.com/files/334602673/Nullsoft.Winamp.v5.572.Build.2830.incl.keymaker-RedT.rar

require 'net/http'
require 'socket'
require 'logger'
require 'dbi'

def ajuda()
  puts "::: Rapidshare V4 :::\n"
  puts ">>> Criado por Samir <samirfor@gmail.com>\n"
  puts "Banco de Dados Postgres necessário para rodar o programa."
end

# CLASSES
class Link
  attr_writer :id_link, :link, :id_pacote, :completado, :tamanho, :id_status
  attr_reader :id_link, :link, :id_pacote, :completado, :tamanho, :id_status

  def initialize(id_link, link, id_pacote, id_status)
    @id_link = id_link
    @link = link
    @id_pacote = id_pacote
    @id_status = id_status
  end
end

# Database functions and constants

# --- STATUS
module Status
  BAIXADO = 1
  OFFLINE = 2
  ONLINE = 3
  BAIXANDO = 4
  AGUARDANDO = 5
  INTERROMPIDO = 6
end

# --- PRIORIDADE
module Prioridade
  BAIXA = 1
  NORMAL = 2
  NENHUMA = 3
  ALTA = 4
  MUITO_ALTA = 5
end

def update_status_link id_link, tamanho, id_status
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  sql = "UPDATE rs.link SET id_status = #{id_status}, tamanho = #{tamanho} WHERE id_link = #{id_link}"
  conn.do(sql)
  conn.disconnect
end

def update_status_link id_link, id_status
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  sql = "UPDATE rs.link SET id_status = #{id_status} WHERE id_link = #{id_link}"
  conn.do(sql)
  conn.disconnect
end

def update_pacote_completado data, id_pacote
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  sql = "UPDATE rs.pacote SET data_fim = '#{data}', completado = 'true' WHERE id = #{id_pacote}"
  conn.do(sql)
  conn.disconnect
end

def update_data_inicio_link id_link, data
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  sql = "UPDATE rs.link SET data_inicio = '#{data}' WHERE id = #{id_link}"
  conn.do(sql)
  conn.disconnect
end

def update_link_completado id_link, data, id_status
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  sql = "UPDATE rs.link SET data_fim = '#{data}', completado = 'true', id_status = #{id_status} WHERE id = #{id_link}"
  conn.do(sql)
  conn.disconnect
end

def update_pacote_problema id_pacote
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  sql = "UPDATE rs.pacote SET problema = 'true' WHERE id = #{id_pacote}"
  conn.do(sql)
  conn.disconnect
end

# --- RETORNA TODOS OS LINKS DE UM DETERMINADO PACOTE. [ HASH ]
def select_pacote_pendente
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  sql = "SELECT id, nome, MAX(prioridade) AS prioridade_max " +
    "FROM rs.pacote WHERE completado = 'false' AND problema = 'false' " +
    "GROUP BY id, nome, prioridade ORDER BY prioridade desc, id desc LIMIT 1"
  rst = conn.execute(sql)
  begin
    id_pacote = rst.fetch[0]
  rescue Exception => err
    puts "Erro no fetch"
    puts err
    id_pacote = nil
  end
  rst.finish
  conn.disconnect
  id_pacote
end

def select_lista_links(id_pacote)
  array = Array.new
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  sql = "SELECT l.link, l.id_link, l.id_pacote, l.id_status FROM rs.pacote p, rs.link l " +
    "WHERE l.id_pacote = p.id AND p.id = #{id_pacote}"
  rst = conn.execute(sql)
  rst.fetch do |row|
    array.push Link.new(row["id_link"], row["link"], row["id_pacote"], row["id_status"])
  end
  rst.finish
  conn.disconnect
  array.sort
end

def select_status_link id_pacotes
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  sql = "SELECT count(id_link) FROM rs.link WHERE id_pacote = #{id_pacotes} "
  rst = conn.execute(sql)
  count_pacotes = rst.fetch[0]
  rst.finish

  sql = "SELECT count(id_link) FROM rs.link WHERE id_pacote = #{id_pacotes} AND id_status = 1 "
  rst = conn.execute(sql)
  count_baixados = rst.fetch[0]
  rst.finish
  conn.disconnect

  return count_pacotes - count_baixados
end

def save_records(texto)
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  # formatar hora
  tempo = Time.new.strftime("%d/%m/%Y %H:%M:%S")
  # processo
  processo = Process.pid.to_s
  conn.do("INSERT INTO rs.historico (data, processo, mensagem) values ('#{tempo}', '#{processo}', '#{texto}')")
  conn.disconnect
end

# --- Database ---

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
#  logger = Logger.new('rs.log', 10, 1024000)
#  logger.datetime_format = "%d/%m %H:%M:%S"
#  logger.info(texto)
#  logger.close
  #  to_xml(texto)
  save_records(texto)
  puts texto
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
        ## Captura tamanho do arquivo
        tamanho = body.scan(/\| (\d+) KB/i)[0][0]
        if tamanho == nil # Testa se identificou o tamanho
          to_log('Não foi possível capturar o tamanho.')
        else
          tamanho = tamanho.to_i
          to_log("Tamanho #{tamanho} KB ou #{tamanho/1024.0} MB")
          $tamanho_total += tamanho
        end
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
def baixar(link)
  if FileTest.exist?("cancelar")
    to_log "Downloads cancelado pelo usuário."
    exit
  end
  to_log("Baixando o link: "+link)
  if link =~ /http:\/\/\S+\/.+/
    url = URI.parse(link)
  else
    to_log("ERRO: Link #{link} inválido evitado.")
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
  begin
    begin
      $tamanho_total = 0

      id_pacote = select_pacote_pendente
      if id_pacote == nil
        to_log "Não há pacotes resgistrados para download."
        exit(1)
      end
      links_before_test = select_lista_links(id_pacote)

      to_log ">> Testando os links........"
      links_online = Array.new
      links_before_test.each do |link|
        if testa_link(link.link.strip)
          links_online.push(link)
          update_status_link(link.id_link, link.tamanho, Status::ONLINE)
        else
          update_status_link(link.id_link, Status::OFFLINE)
        end
      end

      to_log ">> Tamanho total: #{$tamanho_total/1024.0} MB"
      links_online.sort.each do |link|
        begin
          update_status_link(link.id_link, Status::BAIXANDO)
          resp = baixar(link.link.strip)
          unless resp
            falhou(10)
          else
            update_link_completado(link.id_link, Time.now.strftime("%d/%m/%Y %H:%M:%S"), Status::BAIXADO)
          end
        end while !resp
      end
      to_log("Fim do pacote.")
      to_log("********************")
      if select_status_pacote == 0
        update_pacote_completado(Time.now.strftime("%d/%m/%Y %H:%M:%S"), id_pacote)
      else
        update_pacote_problema(id_pacote)
      end
    rescue Exception => err
      to_log err
      retry
    end
  end while id_pacote != nil
  to_log("Fim do(s) download(s).")
  to_log("########################")
end

# O main do programa
begin
  ajuda
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
