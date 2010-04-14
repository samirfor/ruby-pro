require 'rubygems'
require 'feed_tools'
require "sms_novo"
require "celular"

feed = FeedTools::Feed.open('http://twitter.com/statuses/user_timeline/20011969.rss')

#puts feed.title
#puts feed.link
#puts feed.description

#for item in feed.items
##  puts item.title
##  puts item.link
#  puts item.content
#end

LIMITE = 116

def envia msg
  msg.delete!("legendas: ")
  if msg.size > LIMITE
      puts "Tamanho ultrapassou o limite. Truncando pra caber..."
      msg.slice!(0...LIMITE)
    end
    sms = SMS::trata_caracteres_invalidos(msg)
    sms = SMS::enviar(Celular.new(85, 88041544), msg)
    puts sms
end

feed.items.each do |post|
  if post.content =~ /Lost/i
    envia post.content
  end
end