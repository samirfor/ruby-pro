require 'rubygems'
require 'feed_tools' # gem install feedtools
#require "sms_novo"
require "sms"
require "celular"

puts "Abrindo RSS..."

def run_threads
  $t1 = Thread.new {
    $feed1 = FeedTools::Feed.open('http://legendas.tv/rss-destaques-series.html')
  }

  $t2 = Thread.new {
    $feed2 = FeedTools::Feed.open('http://twitter.com/statuses/user_timeline/20011969.rss')
  }
end

run_threads
while $t1.alive? and $t2.alive?
  sleep 1
end

feed = nil
unless $t1.alive?
  puts "Feed do Legendas.tv respondeu primeiro."
  feed = $feed1
else
  puts "Feed do Twitter respondeu primeiro."
  feed = $feed2
end

LIMITE = 116

def envia msg
  msg.delete!("legendas: ")
  if msg.size > LIMITE
    puts "Tamanho ultrapassou o limite. Truncando pra caber..."
    msg.slice!(0...LIMITE)
  end
  sms = SMS::trata_caracteres_invalidos(msg)
  sms = SMS::enviar(Celular.new(85, 87954849), msg)
  puts sms
end

puts "Lendo RSS..."
feed.items.each do |post|
  if post.content =~ /How\.I\.Met\.Your\.Mother/i
    puts "Enviando SMS: #{post.content}"
    envia post.content
  end
end