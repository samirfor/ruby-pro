#!/usr/bin/ruby

#############       Dependencias: ruby libtk-ruby
#############       Precisa ser executado como root

require 'tk'

# Configurações
intervalo = 5      # tempo em minutos
delay = 30         # tempo em segundos
tentativa = 1 # iniciando número de tentativas de restabelecer a conexão
$reiniciar_apos = 0 # num de tentativas antes de reiniciar. zero -> desligado
$desligar_apos = 5 # num de tentativas antes de desligar. zero -> desligado

# Testa usuario
if `whoami`.chomp != "root"
  puts "Este programa só funciona perfeitamente se o usuário tiver privilégios de administrador.\n\nTente    \"sudo ./testaConexao.rb\""
  `zenity --error --title='Testa Conexão!' --text='Este programa só funciona perfeitamente se o usuário tiver privilégios de administrador.\n\n<b>Tente    \"sudo ./testaConexao.rb\" </b>'`
  exit
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
  puts "Testando conexão com o roteador ..."
  ping = `ping 10.0.0.1 -c 1`
  ping = ping.to_a.each {|x| x.chomp!}
  ping = ping[1].gsub("From 10.0.0.210 icmp_seq=1 Destination ","")
  if ping == "Net Prohibited" or ping == "Host Prohibited"
    return false
  end
  if ping == "Net Unreachable" or ping == "Host Unreachable"
    return true
  end
  return false
end

def conexao_ok(intervalo)
  t = Time.now
  puts "\nConexão OK em: \t"+t.strftime("%d/%m/%Y %H:%M:%S %A")+
    "\nProxima verificacao em "+intervalo.to_s+" minutos.\n\n"
  sleep(intervalo*60)
end

def to_log(texto)
  puts texto
  arq = File.open( "testaConexao.log", "a" )
  arq.puts(texto)
  arq.flush
  arq.close
end

def reiniciar
  t = Time.now
  to_log("Requisitou reinicialização em: \t"+t.strftime("%d/%m/%Y %H:%M:%S %A"))
  system('shutdown -r 1 &')
  janela("reiniciará")
end

def desligar
  t = Time.now
  to_log("Requisitou desligamento em: \t"+t.strftime("%d/%m/%Y %H:%M:%S %A"))
  system('shutdown -h 1 &')
  janela("desligará")
end

def conexao_falhou(tentativa)
  if tentativa == $reiniciar_apos
    reiniciar
  else
    if tentativa == $desligar_apos
      desligar
    else
      t = Time.now
      to_log("Tentativa de reconexão #"+tentativa.to_s+" em: \t"+t.strftime("%d/%m/%Y %H:%M:%S %A"))
      return 1
    end
  end
end

def tenta_reconexao
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

while true
  if router_off?
    t = Time.now
    to_log("Roteador está offline. Tentando novamente em 10s...\t"+t.strftime("%d/%m/%Y %H:%M:%S %A"))
    sleep(10)
    desligar if router_off?
  end
  pre_request = system('ping google.com -c 1')
  if pre_request == true
    conexao_ok(intervalo)
  else
    request1 = system('ping www.google.com -c 5')
    if request1 == true
      tentativa = 1
      conexao_ok(intervalo)
    else
      request2 = system('ping www.yahoo.com -c 5')
      if request2 == true
        tentativa = 1
        conexao_ok(intervalo)
      else
        tentativa += conexao_falhou(tentativa)
        puts "Tentando reconexão...\n\n"
        tenta_reconexao
        sleep(10)
        system('nice -n 10 firefox www.google.com &')
        #begin
        #     codigo = 200
        #end while codigo != 200 or codigo < 500 # Garante que a repetição não se dará por erro do servidor
        sleep(30)
      end
    end
  end
end