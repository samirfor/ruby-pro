#!/usr/bin/ruby

#############       Dependencias: ruby libtk-ruby
#############       Precisa ser executado como root

require 'tk'
require 'autenticaMD5.rb'
require 'stop_resume.rb'

# Configurações
intervalo = 10      # tempo em minutos
delay = 0          # tempo em segundos
tentativa = 10      # iniciando número de tentativas de restabelecer a conexão
$ip_router = "10.0.0.1"
$ip_cliente = "10.0.0.210"
$pwd = `pwd`.chomp
$reiniciar_apos = 0 # num de tentativas antes de reiniciar. zero -> desligado
$desligar_apos = 20 # num de tentativas antes de desligar. zero -> desligado

# Testa usuario
if `whoami`.chomp != "root"
  puts "Este programa só funciona perfeitamente se o usuário tiver privilégios de administrador.\n\nTente    \"sudo ./testaConexao.rb\""
  `zenity --error --title='Testa Conexão!' --text='Este programa só funciona perfeitamente se o usuário tiver privilégios de administrador.\n\n<b>Tente    \"sudo ./testaConexao.rb\" </b>'`
  exit
end

def to_log(texto)
  logger = Logger.new('testaConexao.log', 10, 1024000)
  logger.datetime_format = "%d/%m %H:%M:%S"
  logger.info(texto)
  logger.close
  puts texto
end

def to_log2(texto)
  logger = Logger.new('testaConexaoCompleto.log', 10, 2048000)
  logger.datetime_format = "%d/%m %H:%M:%S"
  logger.info(texto)
  logger.close
  puts texto
end

# Métodos
def janela(metodo)
  root = TkRoot.new { title "Aviso sobre a rede" }
  TkLabel.new(root) {
    text  "Foi detectada rede inatingível. O computador #{metodo} em 1 minuto."
    pack  { side 'center' }
  }
  TkButton.new(root) {
    text  'Cancelar (não recomendado)'
    command proc { system('sudo shutdown -c &')
      exit
    }
    pack  { side 'center' }
  }
  Tk.mainloop
end

# Testa roteador
def router_off?
  to_log2("Testando conexão com o roteador ...")
  ping = `ping #{$ip_router} -c 2`
  if ping == ""
    return true
  else
    ping = ping.scan(/Host Unreachable/)[0]
    if ping == nil
      to_log2("OK!")
      return false
    else
      return true
    end
  end
end

# Testa autenticação
def autenticado
  to_log2("Testando autenticação HotSpot ...")
  ping = `ping google.com -c 1`
  ping = ping.scan(/Net Prohibited/)[0]
  if ping != nil
    autentica # autenticarMD5.rb
    sleep(10)
    stop # JDownloader
    resume # JDownloader
    return true
  else
    to_log2("OK! Já está autenticado.")
    return true
  end
end

def conexaoOk(intervalo)
  to_log2("Conexão OK.")
  sleep(intervalo*60)
end

def reiniciar
  to_log("Requisitou reinicialização.")
  system('shutdown -r 1 &')
  janela("reiniciará")
end

def desligar
  to_log("Requisitou desligamento.")
  system('shutdown -h 1 &')
  janela("desligará")
end

def conexaoFalhou(tentativa)
  if tentativa == $reiniciar_apos
    reiniciar
  else
    if tentativa == $desligar_apos
      desligar
    else
      to_log("Tentativa de reconexão #"+tentativa.to_s)
      return 1
    end
  end
end

def tentaReconexao
  puts `# Bloco de comandos bash
     sudo /etc/init.d/NetworkManager stop    # Pára
     sudo modprobe -r rt61pci      # Desativa módulo
     sudo modprobe rt61pci         # Ativa módulo
     sudo /etc/init.d/NetworkManager start
     zenity --info --timeout=3 --title="Reconectando..." --text="Reconexão feita com sucesso\!"
     # Fim do bloco`
end



#Fluxo principal
puts "Aguardando delay pré-definido de "+delay.to_s+" segundos para iniciar..."
sleep(delay) # tempo para os processos iniciarem
tentativa = 1

while true
  while router_off?
    to_log("Roteador está offline. Tentando novamente...")
    to_log2("Tentando reconexão...")
    tentativa += conexaoFalhou(tentativa)
    tentaReconexao
    puts "Aguardando..."
    sleep(60)
  end
  begin
    resposta = autenticado
  end while !resposta
  request1 = system('ping yahoo.com -c 5')
  if request1 == true
    tentativa = 1
    conexaoOk(intervalo)
  else
    request2 = system('ping google.com -c 5')
    if request2 == true
      tentativa = 1
      conexaoOk(intervalo)
    else
      tentativa += conexaoFalhou(tentativa)
      to_log2("Tentando reconexão...")
      tentaReconexao
      puts "Aguardando..."
      sleep(60)
    end
  end
end