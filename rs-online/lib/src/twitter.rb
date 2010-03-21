require 'rubygems'
require 'twitter'

def tweet msg
  puts "Twittando..."
  autenticacao = Twitter::HTTPAuth.new 'rsonline_', 'rs4all'
  cliente = Twitter::Base.new autenticacao
  if cliente.user_timeline[0].text == msg
    msg += "."
  end
  cliente.update msg
end