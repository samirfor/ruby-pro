require 'net/http'

def to_html(body)
  arq = File.open("rapid.html", "w")
  arq.print(body)
  arq.close
end

# Send form login_verifica by POST
uri = URI.parse "http://legendas.tv/login_verificar.php"
form_login = Hash.new
form_login["txtLogin"] = 'rsonline'
form_login['txtSenha'] = 'rs4all'
form_login['chkLogin'] = '1'
login = Net::HTTP.post_form(uri, form_login)

p login

=begin
# Open /index.php
http = Net::HTTP.new('legendas.tv')
http.read_timeout = 15 #segundos
puts 'Abrindo conexão HTTP...'
headers, body = http.get("/index.php")
unless headers.code == "200"
  puts "Não foi possível carregar a página."
  puts "#{headers.code} - #{headers.message}"
end
to_html body

# Send form buscalegenda by POST
uri = URI.parse "http://legendas.tv/index.php?opcao=buscarlegenda"
form_busca = Hash.new
form_busca["txtLegenda"] = 'lost dvdrip'
form_busca["selTipo"] = '1'
form_busca["int_idioma"] = '1'
busca = Net::HTTP.post_form(uri, form_busca)
to_html busca.body

=end
puts 'Pronto!'

