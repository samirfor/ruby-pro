# => Captura de erros
def regex string, body
  expressao = nil
  expressao = body.scan(/#{string}/i)[0]
  if expressao == nil
    return false
  else
    return true
  end
end

module ErrorMU
  def self.indisponivel(body)
    if regex("Link que escolheu já não está disponível", body)
      to_log("Link que escolheu já não está disponível reconhecido pelo MU.")
      return true
    else
      return false
    end
  end
  def self.invalido(body)
    if regex("Link inválido", body) or regex("invalid link", body)
      to_log("Link inválido reconhecido pelo MU.")
      return true
    else
      return false
    end
  end
  def self.deletado(body)
    if regex("Este arquivo foi deletado porque violou nossos.*Termos de Serviço", body) \
        or regex("The file has been deleted because it was violating", body)
      to_log("Este arquivo foi deletado porque violou os Termos de Serviço do MU.")
      return true
    else
      return false
    end
  end
  def self.temp_indisponivel body
    if regex("The file you are trying to access is temporarily", body) or \
        regex("No htmlCode read", body) or \
        regex("This service is temporarily not available from your service area", body)
      to_log "O arquivo que está tentando acessar está temporariamente inacessível."
      return true
    else
      return false
    end
  end
  def self.ip_block body
    if regex("A temporary access restriction is place", body) or \
        regex("We have detected an elevated", body) or \
        regex('location=\'http:\/\/www\.megaupload\.com\/\?c=msg', body)
      wait = body.scan(/Please check back in (\d+) minutes/i)[0][0]
      unless wait == nil
        wait = wait.to_i
        to_log "MU bloqueou esse Ip por #{wait} minutos."
      else
        to_log 'Waitime não funcionou! BUG SEVERO!'
      end
      contador(wait, "Aguardando %Hh %Mm %Ss.")
    end
  end
  def big_files body
    if regex("trying to download is larger than", body)
      to_log("MU: Arquivos acima de 1GB precisam de conta premium.")
      return true
    else
      return false
    end
  end
end