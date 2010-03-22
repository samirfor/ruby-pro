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

def to_html(body)
  arq = File.open("rapid.html", "w")
  arq.print(body)
  arq.close
end

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

def get_local_path
  arq = File.open("/home/#{`whoami`.chomp}/rs-online.conf", "r")
  local = arq.readlines[1].split('=')[1].chomp
  arq.close
  local
end

def run_thread proc
  while $thread.alive?
    sleep 1
  end
  $thread = Thread.new {proc.call}
end

def timestamp time
  time.strftime("%Y/%m/%d %H:%M:%S")
end

def teste_paralelo id_pacote_excecao
  pacotes = select_pacotes_pendetes_teste(id_pacote_excecao)
  if pacotes == nil
    to_log "<T> Não há mais pacotes pendetes para testar."
    return
  end
  pacotes.each do |pacote|
    to_log "<T> Testando pacote #{pacote.nome}"
    links_before_test = select_lista_links pacote.id_pacote
    links_before_test.each do |link|
      pacote.tamanho = 0
      if link.id_status == Status::BAIXADO
        pacote.tamanho += link.tamanho
      else
        link.test
        case link.id_status
        when Status::ONLINE
          link.id_status = Status::ONLINE
          pacote.tamanho += link.tamanho
        when Status::OFFLINE
          link.id_status = Status::OFFLINE
        when Status::INTERROMPIDO
          link.id_status = Status::INTERROMPIDO
        end
        link.update_db
      end
    end
    pacote.update_db
  end
  to_log "<T> Fim do teste dos pacotes."
end

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
        if link.id_status == Status::BAIXADO
          pacote.tamanho += link.tamanho
        else
          link.test
          if link.id_status == Status::ONLINE
            pacote.tamanho += link.tamanho
            links_online.push link
          end
          link.update_db        
        end
      end
      pacote.update_db
      ## Fim do teste

      ## Informações do teste
      to_log "Tamanho total: #{sprintf("%.2f MB", pacote.tamanho/1024.0)}"
      run_thread Proc.new {
        tweet "Iniciado download do pacote #{pacote.nome} (#{sprintf("%.2f MB", pacote.tamanho/1024.0)})"
      }
      ## Fim Informações do teste

      ## Inicio THread Testes
      thread_testes = Thread.new {
        teste_paralelo pacote.id_pacote
      }
      ## Fim Thread Testes

      ## Inicio Download do Pacote
      pacote.data_inicio = Time.now # Marca quando o pacote iniciou download
      links_online.each do |link|
        cancelar?
        begin
          link.download
          if link.id_status == Status::TENTANDO
            falhou 10 #segundos
          end
        end while link.id_status == Status::TENTANDO
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
  arq_conf = "/home/#{`whoami`.chomp}/rs-online.conf"
  unless FileTest.exist? arq_conf
    return true
  end
  arq = File.open(arq_conf, "r")
  pid = arq.readlines[0].split("=")[1].chomp
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
    arq = File.open("/home/#{`whoami`.chomp}/rs-online.conf", "r+")
    txt = arq.readlines
    txt[0] = "Pid (não mexer)=#{Process.pid}\n"
    arq.puts txt
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
rescue NoMethodError => err
  to_log "FATAL: Não há método definido."
  exit!
rescue Exception => err
  to_log err
  abort
end
