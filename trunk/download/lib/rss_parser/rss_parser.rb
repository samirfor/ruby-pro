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
  #exemplo fonte => "http://www.onelinkmoviez.com/feeds/posts/default?alt=rss"
  content = ""
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

def browser(host, path)
  begin
    req = Net::HTTP::Get.new(path)
    res = Net::HTTP.start(host, 10025) do |http|
      http.request(req)
    end
    puts res.body
  rescue Timeout::Error
    puts("Tempo de requisição esgotado. Tentando novamente.")
    retry
  rescue Exception => err
    STDERR.puts err
    puts(err)
  rescue
  end
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
    puts "Lista salva com sucesso."
  else
    puts "Não há links se serem salvados."
  end
  if ARGV[0] =~ /JD/i
    puts "\nAdicionando links ao JDownloader."
    unless ARGV[1] == nil
      jdownloader = ARGV[1]
      action = "/action/add/links/grabber0/start1/?d="
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
        browser(ARGV[1], action)
      else
        puts "Nenhum link foi adicionado no JD."
        File.delete("lista")
      end
    end
  else
    puts "Especifique o host do JDownloader."
    exit(1)
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