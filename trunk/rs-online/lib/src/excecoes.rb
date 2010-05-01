$twitter = true
begin
  require 'src/twitter'
rescue Exception => e
  $twitter = false
  to_log "Não foi possível carregar o twitter: #{e.message}"
end

def interrupt
  to_log "\nSinal de interrupção recebido"
  to_log "O programa foi encerrado."
  if $twitter
    RSTwitter.tweet "O programa foi encerrado." 
  else
    puts "Não foi possível twittar. Veja log para mais detalhes."
  end
  exit!(1)
end