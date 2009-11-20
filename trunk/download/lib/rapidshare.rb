$arquivo_log = "download.log"

def url_parse(link)
  url = URI.parse(link)
  url.host = get_ip(url.host)
  URI.parse('http://' + url.host + url.path)
end

def to_log(texto)
  logger = Logger.new($arquivo_log, 10, 1024000)
  logger.datetime_format = "%d/%m %H:%M:%S"
  logger.info(texto)
  logger.close
  puts texto
end

def get_justify(body)
  justify = nil
  justify = body.scan(/<p align=\"justify\">.+<\/p>/)[0]
  if justify != nil
    justify.gsub!("<p align=\"justify\">", "").gsub!("</p>", "")
    to_log(justify)
    return true
  else
    return false
  end
end

def get_no_slot(body)
  str = nil
  str = body.scan(/no more download slots available/)[0]
  if str != nil
    to_log("Não há slots disponíveis no momento.")
    return true
  else
    return false
  end
end

def warning_link_premium(body)
  str = nil
  str = body.scan(/need a Premium Account/)[0]
  if str != nil
    to_log("Este link so pode ser baixado com uma Conta Premium.")
    return true
  else
    return false
  end
end

def respaw(body)
  time = nil
  time = body.scan(/try again in about \d+ minutes/)[0]
  if time != nil
    time.gsub!("try again in about ","").gsub!(" minutes","")
    to_log("Respaw de #{time} minutos.")
    sleep(60*time.to_i-10)
    return true
  else
    return false
  end
end

def waiting(body)
  wait = body.scan(/Please try again in \d+ minutes/)[0]
  if wait != nil
    wait.gsub!("Please try again in ","").gsub!(" minutes","")
    to_log("Tentando novamente em #{wait.to_s} minutos.")
    sleep(60*wait.to_i-10)
    return true
  else
    return false
  end
end

def simultaneo(body)
  str = nil
  tempo = 2
  str = body.scan(/already downloading a file/)[0]
  if str != nil
    to_log("Ja existe um download corrente.")
    to_log("Tentando novamente em #{tempo.to_s} minutos.")
    sleep(60*tempo-10)
    return true
  else
    return false
  end
end

def ident_server(body)
  servidor_host = body.scan(/rs\w{1,}.rapidshare.com/)[0]
  ## Testa se identificou o host
  if servidor_host == nil
    to_log("Não foi possível capturar o servidor.")
    to_log("Verifique se a URL está correta.")
    false
  else
    return servidor_host
  end
end

def baixar_rs(link)
  url = URI.parse(link)
  url.host = get_ip(url.host)
  begin
    http = Net::HTTP.new(url.host)
    to_log('Abrindo conexão HTTP...')
    headers, body = http.get(url.path)
    if headers.code == "200"
      to_log('Conexão HTTPOK 200.')
      host = ident_server(body)
      if !host
        return false
      end
      to_log('Servidor ' + host + ' identificado.')
      size = body.scan(/\| (\d+) KB/)[0][0]
      to_log("Tamanho do arquivo: "+size+" KB ou "+(size.to_f/1024).to_s+" MB")
      servidor_ip = get_ip(host)
      ## Tratando a resposta do POST (1)
      ip_url = "http://" + servidor_ip + url.path
      to_log('Enviando requisição de download...')
      res = Net::HTTP.post_form(url_parse(ip_url), {'dl.start'=>'Free'})
      return false if respaw(res.body)
      return false if waiting(res.body)
      return false if get_no_slot(res.body)
      return false if warning_link_premium(res.body)
      return false if get_justify(res.body)
      return false if simultaneo(res.body)
      ## Captura tempo de espera
      tempo = res.body.scan(/var c=\d{1,};/)[0]
      if tempo == nil # Testa se identificou o contador
        to_log('Não foi possível capturar o contador.')
        return false
      end
      tempo.gsub!("var c=", "").gsub!(";","")
      to_log("Contador identificado: #{tempo} segundos.")
      contador(tempo.to_i+1,"O download começará em %Hh %Mm %Ss")

      download = res.body.scan(/dlf.action=\\\'\S+\\/)[0]
      download.gsub!("dlf.action=\\'","").gsub!("\\","")
      to_log("Link para download: #{download}")

      ## Download com wget
      baixou = system("wget -c #{download}")
      if baixou
        to_log("Download concluido com sucesso.")
        to_log("============")
      else
        to_log("Download falhou.")
        to_log("============")
      end
    else
      to_log("#{headers.code} #{headers.message}")
    end
    return baixou
  rescue Timeout::Error
    to_log("Tempo de requisição esgotado. Tentando novamente.")
    retry
  end
end