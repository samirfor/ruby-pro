require "src/sms"

LIMITE = 116

txt = "Esta é uma mensagem automática. LOL"
if txt.size > LIMITE
  puts "Tamanho ultrapassou o limite."
  return
end
txt = SMS::trata_caracteres_invalidos(txt)
puts "Texto tratado:\n\"#{txt}\""
sms = SMS::enviar(txt)
puts sms