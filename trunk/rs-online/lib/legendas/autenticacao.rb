require 'net/http'

def to_html(body)
  arq = File.open("legendas.html", "w")
  arq.print(body)
  arq.close
end

uri = URI.parse "http://legendas.tv/index.php"
http = Net::HTTP.new(uri.host)

# GET resquest => so host can set his cookie
resp, data = http.get(uri.path, nil)
cookie = resp.response["set-cookie"]
#puts "Cookie = #{cookie}"
p cookie.split(";")

# POST request => logging in
data = "txtLogin=rsonline&txtSenha=rs4all&chkLogin=1"
headers = {
  'Cookie' => cookie,
  'Referer' => "http://legendas.tv/login_verificar.php"
}

resp, data = http.post(uri.path, data, headers)

puts "Code = #{resp.code}"
puts "Message = #{resp.message}"
resp.each do |key, val|
  puts "#{key} = #{val}"
end
to_html data
exit!

# Send form login_verifica by POST
uri = URI.parse "http://legendas.tv/login_verificar.php"
#form_login = Hash.new
#form_login["txtLogin"] = 'rsonline'
#form_login['txtSenha'] = 'rs4all'
#form_login['chkLogin'] = '1'
#login = Net::HTTP.post_form(uri, form_login)


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

