require "src/twitter"

def interrupt
  to_log "\nSinal de interrupção recebido"
  to_log "O programa foi encerrado."
  tweet "O programa foi encerrado."
  exit!(1)
end

def reconhecer_servidor body
  servidor_host = nil
  servidor_host = body.scan(/rs\w{1,}.rapidshare.com/i)[0]
  if servidor_host == nil
    to_log("Não foi possível reconhecer o servidor.")
    to_log("Verifique se a URL está correta. Evitando ...")
    return nil
  end
  to_debug('Servidor ' + servidor_host + ' identificado.')
  servidor_host
end

def error body
  expressao = nil
  expressao = body.scan(/<h1>(error|erro)<\/h1>/i)[0]
  if expressao == nil
    return false
  end
  error_msg = body.scan(/<.*--.*E.*-->(.+)/i)[0]
  unless error_msg == nil
    to_log(error_msg[0] + " Evitando link.")
  else
    to_log("Houve algum erro do rapidshare. Evitando link.")
  end
  return true
end

def error2 body
  expressao = body.scan(/<h1>.*DOWNLOAD.*<\/h1>/i)[0]
  if expressao == nil
    to_log "Há algum problema com o link."
    return true
  else
    return false
  end
end

def blocked body
  expressao = nil
  expressao = body.scan(/suspected to contain illegal content and has been blocked/i)[0]
  if expressao != nil
    to_log("O link foi bloqueado.")
    return true
  else
    return false
  end
end

def lot_of_users(body)
  res = body.scan(/Currently a lot of users are downloading files/i)[0]
  minutos = 2
  if res != nil
    to_log("Atualmente muitos usuários estão baixando arquivos.")
    to_log("Tentando novamente em 2 minutos.")
    contador(60*minutos, "Falta #{"%M min e " if minutos >= 1}%S seg.")
    return true
  else
    return false
  end
end
