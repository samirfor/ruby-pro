#!/usr/bin/env ruby

=begin

puts feed.title
puts feed.link
puts feed.description

for item in feed.items
  puts item.title
  puts item.link
  puts item.content
end

=end


require 'rubygems'
require 'feed_tools'

if ARGV[0] == nil or ARGV[0].chomp == ""
  puts "Qual o nome da série? Ex: ruby #{__FILE__} Smallville"
  abort
end

begin
  loop do

    feed = FeedTools::Feed.open('http://legendas.tv/rss-destaques-series.html')

    feed.items.each do |post|
      if post.title =~ /#{ARGV[0].chomp}/i
        Thread.new {`mpg123 -qo pulse --loop 2 /home/samir/eita_mah.mp3`}
        puts post.title
        puts post.link
        `firefox \"#{post.link}&c=1\"`
        exit!
      end
    end

    puts "#{Time.now}\tNada ainda :\\"
    sleep 5*60
  end
rescue Exception => e
  puts "ERRO: #{e.message}"
  sleep 5
  retry
end
