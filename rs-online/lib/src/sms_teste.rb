require "src/sms"

LIMITE = 116

txt = "açúcar pão xícara café içú nação país corações lingüiça ídolos feijó jô jânio nós"
if txt.size > LIMITE
  puts "Tamanho ultrapassou o limite."
  return
end
txt = SMS::trata_caracteres_invalidos(txt)
puts "Texto tratado:\n\"#{txt}\""
sms = SMS::enviar(txt)
puts sms