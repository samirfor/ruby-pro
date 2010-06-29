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
require 'src/status'
require 'src/prioridade'
require 'src/pacote'
require "src/verbose"


#Usage
def ajuda
  puts "::: RS-Online Beta :::\n"
  puts ">>> Criado por Samir <samirfor@gmail.com>\n"
  puts ">>> Incrementado por Átila <camurca.home@gmail.com>\n"
  puts "Banco de Dados PostgreSQL é necessário para rodar o programa."
  puts "Local da aplicação: #{File.dirname($0)}"
end

# Retorna onde o caminho completo de onde os downloads serão salvos.
def get_local_path
  arq = File.open("/home/#{`whoami`.chomp}/rs-online.conf", "r")
  local = arq.readlines[1].split('=')[1].chomp
  arq.close
  local
end

# Usado para mandar tweet em paralelo. Assim, não perdemos tempo.
def run_thread proc
  while $thread.alive?
    sleep 1
  end
  $thread = Thread.new {proc.call}
end

# Testa os outros links que estão submetidos à download
def teste_paralelo id_pacote_excecao
  pacotes = Pacote.select_pacotes_pendetes_teste(id_pacote_excecao)
  if pacotes == nil
    Verbose.to_log "<T> Não há mais pacotes pendetes para testar."
    return
  end
  pacotes.each do |pacote|
    Verbose.to_log "<T> Testando pacote #{pacote.nome}"
    links_before_test = pacote.select_links
    pacote.tamanho = 0
    links_before_test.each do |link|
      link.tentativas = 0
      if link.id_status == Status::BAIXADO
        pacote.tamanho += link.tamanho
      elsif link.testado and (link.tamanho != nil or link.tamanho != 0)
        pacote.tamanho += link.tamanho
      else
        link.test
        pacote.tamanho += link.tamanho if link.id_status == Status::ONLINE
      end
    end
    pacote.problema = true if pacote.tamanho == 0
    pacote.update_db
  end
  Verbose.to_log "<T> Fim do teste dos pacotes."
end

module Core

  def self.interrupt
    require "src/verbose"

    Verbose.to_log "\nSinal de interrupção recebido"
    Verbose.to_public "O programa foi encerrado."
    exit!(1)
  end
  
	# Contador regressivo
  def self.contador(tempo, mensagem)
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
    rescue
      raise
    end
  end
  def self.falhou(segundos)
    begin
      Verbose.to_log("Tentando novamente em #{segundos} segundos.")
      contador(segundos, "Falta %S segundos.")
    rescue
      raise
    end
  end

  # Verifica se existe algum arquivo chamado "cancelar" ou "fechar" no local
  def self.cancelar?
    fullpath = get_local_path
    if FileTest.exist?("#{fullpath}/cancelar") or FileTest.exist?("#{fullpath}/fechar")
      evento = "Downloads cancelado pelo usuário."
      Verbose.to_public evento
      exit!(1)
    end
  end

  # O mesmo que "cancelar?"
  def self.fechar?
    cancelar?
  end
end

#################
#      Main
#################
def run
  begin
    begin
      Core.cancelar?
      ## Select pacote
      pacote = Pacote.select_pendente
      if pacote == nil
        evento = "Fim do(s) download(s). Have a nice day\!"
        puts evento
        exit!(1)
      end
      links_before_test = pacote.select_links
      if links_before_test == nil
        Verbose.to_log "Não foi possível selecionar a lista de links."
        exit!(1)
      end
      ## Fim do Select pacote

      ## Inicio do teste
      Verbose.to_log "Testando os links de \"#{pacote.nome}\"..."
      links_online = Array.new
      test_threads = Array.new
      links_before_test.each do |link|
        test_threads << Thread.new {
          link.tentativas = 0
          Core.cancelar?
          if link.id_status == Status::BAIXADO
            pacote.tamanho += link.tamanho
          else
            begin
              link.retry_
            end while not link.test
            if link.id_status == Status::ONLINE
              pacote.tamanho += link.tamanho
              links_online << link
            end
            link.update_db
          end
        }
      end
      while test_threads.size != 0
        test_threads.delete_if { |thread| not thread.alive? }
        sleep 1
      end
      pacote.problema = true if pacote.tamanho == 0
      pacote.update_db
      
      ## Fim do teste

      ## Informações do teste
      msg = "Iniciado download do pacote #{pacote.nome} (#{sprintf("%.2f MB", pacote.tamanho/1024.0)})"
      Verbose.to_public(msg)
      ## Fim Informações do teste

      ## Inicio Thread Testes
      Thread.new {
        teste_paralelo pacote.id_pacote
      }
      ## Fim Thread Testes

      ## Inicio Download do Pacote
      pacote.data_inicio = Time.now # Marca quando o pacote iniciou download
      pacote.update_db
      links_before_test.each do |link|
        link.tentativas = 0
        Core.cancelar?
        begin
          begin
            link.retry_
            next if link.id_status == Status::OFFLINE
          end while not link.get_ticket
          next if link.id_status == Status::OFFLINE
          unless link.download
            link.retry_
            next if link.id_status == Status::OFFLINE
          end
        rescue Interrupt
          raise
        rescue Exception => err
          Verbose.to_debug("#{err}\nBacktrace: #{err.backtrace.join("\n")}")
          retry
        end
      end
      
      pacote.data_fim = Time.now
      pacote.completado = true
      pacote.update_db
      ## Fim Download do Pacote

      ## Informações do download
      duracao = Time.local(0) + (pacote.data_fim - pacote.data_inicio)
      evento = "Concluido o download do pacote #{pacote.nome}"
      evento += " em #{duracao.strftime("%Hh %Mm %Ss")} | "
      evento += "V. media = #{sprintf("%.2f KB/s", pacote.tamanho/(pacote.data_fim - pacote.data_inicio))}"
      Verbose.to_public(evento)
      unless pacote.select_count_remaining_links == 0
        pacote.problema = true
        pacote.update_db
        Verbose.to_public "Pacote #{pacote.nome} está problema."
      end
      ## Fim Informações do download
    rescue Interrupt
      raise
    rescue Exception
      raise
    end
  end while pacote != nil
end

# Verifica se outro processo deste programa está sendo executado.
def singleton?
  arq_conf = "/home/#{`whoami`.chomp}/rs-online.conf"
  unless FileTest.exist? arq_conf
    arq = File.open(arq_conf, "w")
    arq.puts "Último Pid=#{Process.pid}"
    arq.puts "Local para downloads=/home/#{`whoami`.chomp}"
    arq.close
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

# O método main do programa
begin
  ajuda
  if singleton?
    # Guardando o numero do pid
    arq = File.open("/home/#{`whoami`.chomp}/rs-online.conf", "r+")
    txt = arq.readlines
    txt[0] = "Pid (não mexer)=#{Process.pid}\n"
    arq.seek(0)
    arq.puts txt
    arq.close
    run
  else
    puts 'Há outro processo rodando nesta máquina.'
    exit!
  end
rescue Interrupt
  Core.interrupt
rescue SystemExit => err
  Verbose.to_public "O programa foi encerrado."
  exit!
rescue NoMethodError => err
  Verbose.to_log "FATAL: Não há método definido.\nBacktrace: #{err.backtrace.join("\n")}"
  exit!
rescue Exception => err
  Verbose.to_log err
  exit!
end
