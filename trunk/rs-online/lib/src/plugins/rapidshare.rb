require "resolv"

class Rapidshare < Link

  attr_accessor :body

  # Método para reconhecimento do servidor de download
  def reconhecer_servidor body
    servidor_host = nil
    servidor_host = body.scan(/rs\w{1,}.rapidshare.com/i)[0]
    if servidor_host == nil
      Historico.to_log("Não foi possível reconhecer o servidor.")
      Historico.to_log("Verifique se a URL está correta. Evitando ...")
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
  # Verifica o estado do link, podendo ele ser:
  #   OFFLINE
  #   ONLINE
  #   INTERROMPIDO
  #   TESTANDO
  # => Rapidshare test
  def test
    begin
      Historico.to_log "Testando link: #{@link}"
      unless @link =~ /http:\/\/\S+\/.+/
        Historico.to_log "ERRO: Sintaxe do link inválido. Evitado."
        @id_status = Status::OFFLINE
        @testado = true
        @data_inicio = StrTime.timestamp Time.now
        update_db
        return
      end
      @id_status = Status::TESTANDO
      @data_inicio = StrTime.timestamp Time.now
      update_db

      body = get_body

      # Requisitando pagina de download
      if ErrorRS::error body or ErrorRS::error2 body
        @id_status = Status::OFFLINE
        @testado = true
        update_db
        return
      end
      ## Captura tamanho do arquivo
      @tamanho = body.scan(/\| (\d+) KB/i)[0][0]
      if @tamanho == nil # Testa se identificou o tamanho
        Historico.to_log 'Não foi possível capturar o tamanho.'
        # Download ainda pode ser feito.
      else
        @tamanho = @tamanho.to_i
        Historico.to_log "Tamanho #{@tamanho} KB ou #{sprintf "%.2f MB", @tamanho/1024.0}"
        @id_status = Status::ONLINE
        @testado = true
        update_db
      end
      return
    rescue Timeout::Error
      Historico.to_log "Tempo de requisição esgotado. Tentando novamente."
      retry
    rescue Exception
      @id_status = Status::INTERROMPIDO
      @testado = false
      update_db
      raise
    end
  end
  def download
    begin
      Historico.to_log("Tentando baixar o link: #{@link}")
      @id_status = Status::TENTANDO
      update_db

      body = get_body

      # Requisitando pagina de download
      to_debug 'Conexão HTTPOK 200.'

      if ErrorRS::error body or ErrorRS::blocked body
        @id_status = Status::OFFLINE
        update_db
        return
      end

      begin
        servidor_host = Rapidshare::reconhecer_servidor body
        if servidor_host == nil
          if retry_ == Status::OFFLINE
            return
          end
        end
      end while servidor_host == nil
      server = ServerRS.new(servidor_host.scan(/\d+/)[0].to_i)

      ## Captura tamanho do arquivo
      expressao = body.scan(/\| (\d+) KB/i)[0][0]
      if expressao == nil # Testa se identificou o tamanho
        Historico.to_log('Não foi possível capturar o tamanho.')
        retry_
        return
      else
        @tamanho = expressao.to_i
        to_debug("Tamanho #{@tamanho} KB ou #{sprintf("%.2f MB", @tamanho/1024.0)}")
      end

      ## Mandando requisição POST
      to_debug('Enviando requisição de download...')
      resposta = Net::HTTP.post_form(URI.parse("http://#{server.ip}#{@uri_original.path}"), {'dl.start'=>'Free'})
      resposta = resposta.body

      if ErrorRS::lot_of_users(resposta) or ErrorRS::respaw(resposta) or \
          ErrorRS::waiting(resposta) or ErrorRS::get_no_slot(resposta) or \
          ErrorRS::simultaneo(resposta) or ErrorRS::get_justify(resposta)
        retry_
        return
      end

      ## Captura tempo de espera
      expressao = resposta.scan(/var c=(\d+)/)[0][0]
      if expressao == nil # Testa se identificou o contador
        Historico.to_log('Não foi possível capturar o contador.')
        retry_
        return
      end
      tempo_inteiro = expressao.to_i
      time = Time.local(0) + tempo_inteiro
      to_debug(time.strftime("Contador identificado: %Hh %Mm %Ss."))
      contador(tempo_inteiro, "O download iniciará em %Hh %Mm %Ss.")

      expressao = resposta.scan(/dlf.action=\\\'\S+\\/)[0]
      expressao.gsub!("dlf.action=\\'","").gsub!("\\","")
      real_uri = URI.parse expressao
      download = "http://#{server.ip}#{real_uri.path}"

      Historico.to_log("Baixando: #{download}")
      time_inicio = Time.now
      @data_inicio = StrTime.timestamp time_inicio
      @id_status = Status::BAIXANDO
      update_db
      ## Download com curl
      baixou = system("curl", "-LO", "#{download}")
      time_fim = Time.now
      @data_fim = StrTime.timestamp time_fim
      duracao = Time.local(0) + (time_fim - time_inicio)
      duracao_str = duracao.strftime("%Hh %Mm %Ss")
      if baixou
        Historico.to_log("D. link concluído com sucesso em #{duracao_str}.")
        Historico.to_log("Velocidade média do link foi de #{sprintf("%.2f KB/s", @tamanho.to_i/(time_fim - time_inicio))}.")
        @id_status = Status::BAIXADO
        @completado = true
      else
        Historico.to_log("Download do link falhou com #{duracao_str} decorridos.")
        @id_status = Status::TENTANDO
      end
      update_db
      return
    rescue Timeout::Error
      Historico.to_log("Tempo de requisição esgotado. Tentando novamente.")
      retry
    rescue Exception
      @id_status = Status::INTERROMPIDO
      raise
    end
  end
end
