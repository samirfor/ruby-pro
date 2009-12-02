#!/usr/bin/env ruby

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

def file_put_a(arquivo, array)
  arq = File.open(arquivo, 'a')
  array.each do |a|
    arq.print(a + "\n") if not ja_inserido(a)
  end
  arq.close
end

def file_to_a(arquivo)
  if not FileTest.exist?(arquivo)
    puts "Arquivo #{arquivo} não existe."
    exit(1)
  end
  arq = File.open(arquivo, "r")
  array = Array.new
  arq.each_line do |linha|
    array.push(linha.chomp)
  end
  arq.close
  array
end

def parse(fonte)
  #fonte = "http://www.onelinkmoviez.com/feeds/posts/default?alt=rss"
  content = "" # raw content of rss feed will be loaded here
  open(fonte) do |s| content = s.read end
  rss = RSS::Parser.parse(content, false)
  rss
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

def run
  puts "Carregando configurações do RSS."
  rss_conf = file_to_a("rss.conf")
  puts "Carregando lista de séries."
  series = file_to_a("series.list")
  rss = parse(rss_conf[0])
  
  links = Array.new
  puts "\nProcurando links...\n"
  series.each do |s|
    rss.items.each do |f|
      if f.title =~ /.*#{s}.*/i
        puts "* " + f.title
        link = f.description
        link = link.scan(/http:\/\/www.megaupload.com\S+\"/)[0].delete("\"")
        if link == nil
          puts "Erro: Não foi possível detectar o link de #{f.title}."
          exit(1)
        else
          links.push(link)
          break
        end
      end
    end
  end
  puts "Salvando lista de links."
  if links.length > 0
    # Escreve a lista de links no final da lista de links
    file_put_a("lista", links)
    puts "Pronto!"
  else
    puts "Não há links se serem salvados."
  end
end

# O main do programa
begin
  run
rescue Interrupt => err
  STDERR.puts "\nSinal de interrupção recebido"
  puts "O programa foi encerrado."
rescue SystemExit => err
  puts "O programa foi encerrado."
rescue Exception => err
  STDERR.puts err
  exit(1)
end