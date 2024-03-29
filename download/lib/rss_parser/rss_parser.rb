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

require 'rss'

def file_put_a(arquivo, array)
  arq = File.open(arquivo, 'a')
  array.each do |a|
    arq.print(a + "\n") if not ja_inserido(a)
  end
  arq.close
end

def file_to_a(arquivo)
  if not FileTest.exist?(arquivo)
    puts "ERRO: Arquivo #{arquivo} não existe."
    exit(1)
  end
  arq = File.open(arquivo, "r")
  array = Array.new
  arq.each_line do |linha|
    array.push(linha.chomp) if not linha =~ /#.*/
  end
  arq.close
  array
end

def ja_inserido(link)
  links = file_to_a("lista")
  links.each do |l|
    if l == link
      return true
    end
  end
  return false
end

def browser(host, path, porta)
  begin
    req = Net::HTTP::Get.new(path)
    res = Net::HTTP.start(host, porta) do |http|
      http.request(req)
    end
    puts res.body
  rescue Timeout::Error
    puts("ERRO: Tempo de requisição esgotado. Tentando novamente.")
    retry
  rescue Exception => err
    STDERR.puts err
    puts(err)
  rescue
  end
end

def jdownloader_insert(links, jd_conf)
  puts "\nINFO: Adicionando links ao JDownloader."
  action = jd_conf[1] + "/action/add/links/grabber0/start1/?d="
  jd_insert = Array.new
  if FileTest.exist?("jd_historico")
    jd_lista = file_to_a("jd_historico")
    links.each do |link|
      achou = false
      jd_lista.each do |jd_link|
        if link == jd_link
          achou = true
          next
        end
      end
      if not achou
        action += "%20" + link
        jd_insert.push(link)
      else
        puts "INFO: #{link} já está no JD."
      end
    end
  else
    arq = File.open("jd_historico", "a")
    arq.close
    links.each do |link|
      action += "%20" + link
      jd_insert.push(link)
    end
  end
  if jd_insert.length > 0
    arq = File.open("jd_historico", 'a')
    jd_insert.each do |a|
      arq.print(a + "\n")
    end
    arq.close
    browser(jd_conf[1], action, 10025)
  else
    puts "INFO: Nenhum link foi adicionado no JD."
    File.delete("lista")
  end
end

def parse(fonte)
  rss = nil
  begin
    rss = RSS::Parser.parse(fonte)
  rescue RSS::InvalidRSSError
    rss = RSS::Parser.parse(fonte, false)
  rescue RSS::Error => err
    STDERR.puts err
    puts "ERRO: Erro no parse do RSS."
    puts err
    exit(1)
  end
  rss
end

# Escreve uma lista de links de interesse de acordo com o arquivo series.list
# e adiciona ao JDownloader ou não.
# server : String
# add_jd : Boolean
def run(server)
  puts "INIT: Carregando configurações do RSS."
  rss_conf = file_to_a("rss.conf")[1]
  puts "INIT: Carregando configurações do JDownloader."
  jd_conf = file_to_a("jdownloader.conf")
  puts "INIT: Carregando lista de séries."
  series = file_to_a("series.list")
  puts "INIT: Carregando lista de exceções."
  excecoes = file_to_a("excecoes.list")
  puts "INIT: Conectando ao feed RSS..."
  rss = parse(rss_conf)
  puts "INIT: RSS versão: " + rss.version
  links = Array.new

  puts "\nINFO: Procurando links...\n"


  rss.items.each do |r|
    series.each do |s|
      achou_excecao = false
      excecoes.each do |e|
        if r.title =~ /.*#{e}.*/i
          achou_excecao = true
        end
      end

      unless achou_excecao

      end
    end
  end

  series.each do |s|
    rss.items.each do |f|
      if f.title =~ /.*#{s}.*(HDTV|DVDRip).*XviD.*/i
        excecoes.each do |e|
          if f.title =~ /.*#{e}.*/i
            next
          end
        end
        puts "+ " + f.title
        link = f.description
        case server
        when "www.megaupload.com" then
          link = link.split("\"")
        when "rapidshare.com" then
          link = link.split("\n")
        end
        link = link.delete_if { |e| not (e =~ /.*http:\/\/#{server}.*/i) }
        if link == nil or link.nitems == 0
          puts "\nErro: Não foi possível detectar o(s) link(s) de #{rss.items[i].title}."
          abort
        else
          link.each do |lk|
            links.push(lk)
          end 
          puts link, "\n"
          break
        end
      end
    end
  end
  puts "\nINFO: Salvando lista de links."
  if links.length > 0
    # Escreve a lista de links no final da lista de links
    file_put_a("lista", links)
    puts "INFO: Lista salva com sucesso."
  else
    puts "ERRO: Não há links se serem salvados."
  end
  if jd_conf[3] == "ativado"
    puts "INFO: JD ativado."
    jdownloader_insert(links, jd_conf)
  else
    puts "INFO: JD desativado."
  end
end

def main(server)
  begin
    run(server)
  rescue Interrupt => err
    STDERR.puts "\nINTERRUPT: Sinal de interrupção recebido"
    puts "INTERRUPT: O programa foi encerrado."
    exit(1)
  rescue SystemExit => err
    puts "INTERRUPT: O programa foi encerrado."
    exit
  rescue Exception => err
    STDERR.puts err
    exit(1)
  end
end

# Argumentos
unless ARGV[0] == nil
  if ARGV[0] =~ /MU/i
    puts ">> Parse para Megaupload"
    main("www.megaupload.com")
  elsif ARGV[0] =~ /RS/i
    puts ">> Parse para Rapidshare"
    main("rapidshare.com")
  else
    puts "ERRO: Parâmetro inválido."
    puts "\tColoque o servidor (RS ou MU) como parâmetro."
    exit(1)
  end
end
