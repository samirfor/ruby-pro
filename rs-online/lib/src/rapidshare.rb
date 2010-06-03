require "resolv"

class Rapidshare

  attr_accessor :body

  # Método para reconhecimento do servidor de download
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
  
  # Testa se identificou o tamanho
  def get_size body
    expressao = body.scan(/\| (\d+) KB/i)[0][0]
    unless expressao == nil 
      tamanho = expressao.to_i
    end
    return tamanho
  end

  def get_countdown

  end
end
