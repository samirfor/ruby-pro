=begin
Sempre gostei da web "por dentro", para ser mais especifico, dos protocolos e
por conseqüência das conexões e portas. Gosto de entender como as coisas
funcionam. Um tempo atrás eu estava intrigado com o login do orkut, queria
entender como o Google tratava a autenticação de um serviço. Comecei a analisar
os requests com o Firebug e até sniffer (Wireshark). Depois de bastante
insistência consegui construir um script que fazia login no orkut, fazendo
autenticação no Google. Depois de um baita esforço eu fui descobrir que o Google
disponibiliza uma documentação sobre autenticação em sua base - mais uma lição:
procure antes.

O artigo de hoje é sobre isso: como conectar no orkut com um script Ruby? Abaixo
do código vou explicar o que fiz. Vale lembrar que essa não é a melhor
implementação - construir um objeto seria a melhor -, mas esse não é o objetivo
do Snapshot, aqui são códigos curtos com grandes funcionalidades.
=end

require 'net/http'
require 'net/https'
require "socket"

@user = 'samirfor@gmail.com'
@pass = '200811080024'

@google = Net::HTTP.new 'www.google.com', 443
@google.use_ssl = true
@google.verify_mode = OpenSSL::SSL::VERIFY_NONE
auth = @google.get("/accounts/ClientLogin?Email=#{@user}&Passwd=#{@pass}&service=orkut").body.split("\n")[2].gsub('Auth', 'auth')

@orkut = Net::HTTP.new(IPSocket.getaddress 'www.orkut.com')
cookie_parts = @orkut.get("/RedirLogin.aspx?msg=0&#{auth}")['set-cookie'].split(';')
@cookie = "#{cookie_parts[0]};#{cookie_parts[3]};"

resp = @orkut.get('/Home.aspx', 'Cookie' => @cookie).body

File.open('resp.html', 'w') { |file| file << resp }

=begin

Vejam que o código está organizado em seis blocos separados por uma linha em
branco. No primeiro coloco os "requires" necessários para fazer os requests
ao orkut e Google. Vou usar a forma segura de autenticação (HTTPS). No segundo
bloco crio duas variáveis, nome do usuário e senha da conta no Google. Até aí,
nada de mais.

No terceiro bloco crio um objeto Net::HTTP para o host www.google.com na porta
padrão para HTTPS, 443. Depois atribuo valores relativos ao tipo de conexão
segura (SSL). Agora vem uma parte importante, é necessário pegar o token de
autenticação no Google, é uma chave que será usada para acessar o orkut - a
"prova da autenticação sucedida". Para pegá-la faço um request a
/accounts/ClientLogin passando usuário, senha e o nome do serviço que quero
fazer login, nesse caso, o orkut. Faço um tratamento com o retorno do request
e coloco dentro da variável auth.

Agora vamos ao orkut, no quarto bloco. Crio um objeto HTTP para o host
www.orkut.com e faço um request em /RedirLogin.aspx, passando a chave de
autenticação que recebi do Google. Do retorno do request, pego o cabeçalho
HTTP set-cookie. Esse cabeçalho solicita ao navegador - no nosso caso,
script - que há um novo valor de cookie para armazenar. Esse cookie é muito
importante, ele armazena a chave das nossas informações no servidor do orkut,
 a famosa chave de sessão.

Já estou logado no orkut! Agora só preciso fazer um request a qualquer página
interna que terei seu conteúdo como retorno - só não se esqueça do cookie. No
exemplo faço um request à pagina inicial do usuário, mas poderia ser um outro
perfil, comunidade e até uma busca no conteúdo do orkut. Depois salvo o
resultado em um arquivo HTML, é só abrir no browser pra conferir.

Com poucas modificações é possível fazer login em outros serviços do Google,
como GMail por exemplo.

Agora você pode conferir aquele perfil que é proibido pela patroa e ainda dizer
que está programando!

=end