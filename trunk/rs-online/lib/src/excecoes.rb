require "src/twitter"

def interrupt
  to_log "\nSinal de interrupção recebido"
  to_log "O programa foi encerrado."
  Twitter.tweet "O programa foi encerrado."
  exit!(1)
end