require 'rubygems'
require 'twitter'

def tweet msg
  puts "Twittando..."
  autenticacao = Twitter::HTTPAuth.new 'rsonline_', 'rs4all'
  cliente = Twitter::Base.new autenticacao
  cliente.update msg
end