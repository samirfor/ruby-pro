# => Captura de erros

module ErrorMU
  def self.indisponivel(body)
    expressao = nil
    expressao = body.scan(/Link que escolheu já não está disponível/i)[0]
    if expressao == nil
      return false
    end
    to_log("Link que escolheu já não está disponível reconhecido pelo MU.")
    return true
  end
  def self.invalido(body)
    expressao = nil
    expressao = body.scan(/Link inválido/i)[0]
    if expressao == nil
      return false
    end
    to_log("Link inválido reconhecido pelo MU.")
    return true
  end
  def self.deletado(body)
    expressao = nil
    expressao = body.scan(/Este arquivo foi deletado porque violou nossos.*Termos de Serviço/i)[0]
    if expressao == nil
      return false
    end
    to_log("Este arquivo foi deletado porque violou os Termos de Serviço do MU.")
    return true
  end
end



=begin
	<TD>- Link inválido</TD>
</TR>
<TR>
	<TD>- Este arquivo foi deletado porque violou nossos <a href="?c=terms">Termos de Serviço</a>.</TD>



# Retorna true quando não há slots disponíveis.
def get_no_slot(body)
  expressao = nil
  expressao = body.scan(/no more download slots available/)[0]
  if expressao == nil
    return false
  end
  to_log("Não há slots disponíveis no momento.")
  return true
end

# Retorna quando um servidor não está disponível no momento.
def server_maintenance(body)
  expressao = nil
  expressao = body.scan(/The server \d+.rapidshare.com is momentarily not available/i)[0]
  if expressao == nil
    return false
  end
  server = expressao.scan(/\d+/)[0]
  to_log("O servidor do rapidshare #{server} está em manutenção. Evitando")
  return true
end

# Verifica se há algum tempo de espera entre downloads.
# Se houver, ele espera o tempo determinado.
def respaw(body)
  minutos = nil
  minutos = body.scan(/try again in about \d+ minutes/i)[0]
  if minutos == nil
    return false
  end
  minutos.gsub!("try again in about ","").gsub!(" minutes","")
  to_log("Respaw de #{minutos} minutos.")
  minutos = minutos.to_i
  contador(60*minutos, "Falta #{"%M min e " if minutos >= 1}%S seg.")
  return true
end

# Detecta a mensagem de tentar novamente em x minutos.
def waiting(body)
  minutos = body.scan(/Please try again in \d+ minutes/i)[0]
  if minutos == nil
    return false
  end
  minutos.gsub!("Please try again in ","").gsub!(" minutes","")
  to_log("Tentando novamente em #{minutos.to_s} minutos.")
  minutos = minutos.to_i
  contador(60*minutos.to_i, "Falta #{"%M min e " if minutos >= 1}%S seg.")
  return true
end

# Detecta se há algum download sendo feito por este mesmo IP.
def simultaneo(body)
  expressao = nil
  minutos = 2
  expressao = body.scan(/already downloading a file/i)[0]
  if expressao == nil
    return false
  end
  to_log("Ja existe um download corrente.")
  to_log("Tentando novamente em #{minutos} minutos.")
  contador(60*minutos, "Falta #{"%M min e " if minutos >= 1}%S seg.")
  return true
end

# Detecta qualquer outro erro que venha a ocorrer.
def get_justify body
  justify = nil
  justify = body.scan(/<p align=\"justify\">.+<\/p>/i)[0]
  if justify == nil
    return false
  end
  justify.gsub!("<p align=\"justify\">", "").gsub!("</p>", "")
  to_log(justify)
  return true
end

# Verifica se a página contém o título "Erro"
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

# Verifica se a página contém o título "DOWNLOAD"
def error2 body
  expressao = body.scan(/<h1>.*DOWNLOAD.*<\/h1>/i)[0]
  if expressao == nil
    to_log "Há algum problema com o link."
    return true
  else
    return false
  end
end

# Detecta a mensagem que o link foi bloqueado por conteúdo ilegal
def blocked body
  expressao = nil
  expressao = body.scan(/suspected to contain illegal content and has been blocked/i)[0]
  if expressao == nil
    return false
  end
  to_log("O link foi bloqueado.")
  return true
end

# Detecta a mensagem de que muitos estão baixando arquivos no momento
def lot_of_users(body)
  res = body.scan(/Currently a lot of users are downloading files/i)[0]
  minutos = 2
  if res == nil
    return false
  end
  to_log("Atualmente muitos usuários estão baixando arquivos.")
  to_log("Tentando novamente em 2 minutos.")
  contador(60*minutos, "Falta #{"%M min e " if minutos >= 1}%S seg.")
  return true
end

=end