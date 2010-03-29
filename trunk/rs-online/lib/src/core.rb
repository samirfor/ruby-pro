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

# Gera linhas de log para debug
def to_debug texto
  ARGV.each do |arg|
    if arg == "debug"
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

def to_html(body)
  arq = File.open("rapid.html", "w")
  arq.print(body)
  arq.close
end

# Verifica se existe algum arquivo chamado "cancelar" ou "fechar" no local
def cancelar?
  fullpath = get_local_path
  if FileTest.exist?("#{fullpath}/cancelar") or FileTest.exist?("#{fullpath}/fechar")
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

# Retorna uma string na forma ideal para o UPDATE no BD.
def timestamp time
  time.strftime("%Y/%m/%d %H:%M:%S")
end

# Método para reconhecimento do servidor de download do rapidshare
def reconhecer_servidor body
  servidor_host = nil
  servidor_host = body.scan(/rs\w{1,}.rapidshare.com/i)[0]
  if servidor_host == nil
    to_log("Não foi possível reconhecer o servidor.")
    to_log("Verifique se a URL está correta. Evitando ...")
    return nil
  end
  to_debug('Servidor ' + servidor_host + ' identificado.')
  servidor_host
end

# Testa os outros links que estão submetidos à download
def teste_paralelo id_pacote_excecao
  pacotes = select_pacotes_pendetes_teste(id_pacote_excecao)
  if pacotes == nil
    to_log "<T> Não há mais pacotes pendetes para testar."
    return
  end
  pacotes.each do |pacote|
    to_log "<T> Testando pacote #{pacote.nome}"
    links_before_test = select_lista_links pacote.id_pacote
    pacote.tamanho = 0
    links_before_test.each do |link|
      if link.id_status == Status::BAIXADO
        pacote.tamanho += link.tamanho
      elsif link.testado and link.tamanho != nil and link.tamanho == 0
        pacote.tamanho += link.tamanho
      else
        link.test
      end
    end
    pacote.problema = true if pacote.tamanho == 0
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
        evento = 'Fim do(s) download(s). Have a nice day!'
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
      to_log "Testando os links de \"#{pacote.nome}\"..."
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
      pacote.problema = true if pacote.tamanho == 0
      pacote.update_db
      
      ## Fim do teste

      ## Informações do teste
      msg = "Iniciado download do pacote #{pacote.nome} (#{sprintf("%.2f MB", pacote.tamanho/1024.0)})"
      to_log msg
      run_thread Proc.new {
        tweet msg
      }
      ## Fim Informações do teste

      ## Inicio Thread Testes
      thread_testes = Thread.new {
        teste_paralelo pacote.id_pacote
      }
      ## Fim Thread Testes

      ## Inicio Download do Pacote
      pacote.data_inicio = Time.now # Marca quando o pacote iniciou download
      pacote.update_db
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
      pacote.completado = true
      pacote.update_db
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
      unless select_remaining_links(pacote.id_pacote) == 0
        pacote.problema = true
        pacote.update_db
        run_thread Proc.new {
          tweet "Pacote #{pacote.nome} está problema."
        }
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
  exit!
end
