require 'rubygems'
require 'twitter'

def tweet msg
  autenticacao = Twitter::HTTPAuth.new 'rsonline_', 'rs4all'
  cliente = Twitter::Base.new autenticacao
  cliente.update msg
end