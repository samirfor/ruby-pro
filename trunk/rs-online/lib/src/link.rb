require 'net/http'
require 'socket'
require "uri"
require "httpclient" # gem install httpclient
require "src/status"
require "src/banco"

class Link
  attr_accessor :link, :path, :ip, :uri_original, :uri_parsed, :id_link, :id_pacote, \
    :completado, :tamanho, :id_status, :tentativas, :max_tentativas, \
    :data_inicio, :data_fim, :testado, :waittime, :downloadlink, :filename

  def initialize link
    @link = link.strip
    @uri_original = URI.parse link
    @id_link = nil
    set_ip
    @tentativas = 1
    @max_tentativas = 20
    @completado = false
    @tamanho = 0
    @id_status = Status::AGUARDANDO
    @data_fim = nil
    @data_inicio = nil
    @testado = false
    @waittime = 0
    @downloadlink = nil
    #    define_server
  end

  def get_body
    http = HTTPClient.new
    #    http.timeout_scheduler 15 #segundos
    begin
      response = http.get(@uri_parsed)
      unless response.header.status_code == 200
        Historico.to_log "Não foi possível carregar a página."
        Historico.to_log "#{response.header.status_code} - #{response.header.reason_phrase}"
        if retry_ == Status::OFFLINE
          return
        end
      end
    end while response.header.status_code != 200
    response.body.content
  end

  # Escreve os dados no BD.
  def update_db
    sql = "UPDATE rs.link SET "
    sql += "link = ?," unless @link == nil
    @tamanho ? sql += "tamanho = '#{@tamanho}', " : sql += "tamanho = NULL, "
    @testado ? sql += "testado = '#{@testado}', " : sql += "testado = DEFAULT, "
    @data_inicio ? sql += "data_inicio = '#{@data_inicio}', " : sql += "data_inicio = NULL, "
    @data_fim ? sql += "data_fim = '#{@data_fim}', " : sql += "data_fim = NULL, "
    @completado ? sql += "completado = '#{@completado}', " : sql += "completado = DEFAULT, "
    @filename ? sql += "filename = '#{@filename}', " : sql += "filename = NULL, "
    sql += "id_status = #{@id_status} "
    sql += "WHERE id_link = ? "
    if @link == nil
      Banco.instance.db_connect.do(sql, @id_link)
    else
      Banco.instance.db_connect.do(sql, @link, @id_link)
    end
  end

  # Traduz hostname da URL para ip.
  # Retorno: String IP
  def set_ip
    begin
      @ip = Resolv::DNS.new
      @ip = @ip.getaddress(@uri_original.host)
      @uri_parsed = @uri_original.clone
      @uri_parsed.host = @ip.to_s
    rescue Exception
      #      if @uri_original.host == "rapidshare.com" or @uri_original.host == "www.rapidshare.com"
      #        @ip = "195.122.131.2"
      #      elsif @uri_original.host == "megaupload.com" or @uri_original.host == "www.megaupload.com"
      #        @ip = "174.140.154.25"
      #      elsif @uri_original.host == "4shared.com" or @uri_original.host == "www.4shared.com"
      #        @ip = "72.233.72.133"
      #      elsif @uri_original.host =~ /rs\d+\.rapidshare\.com/
      #        server = ServerRS.new(@uri_original.host.scan(/\d+/)[0].to_i)
      #        @ip = server.ip
      #      elsif @uri_original.host =~ /www\d+\.megaupload\.com/
      #        server = ServerMU.new(@uri_original.host.scan(/\d+/)[0].to_i)
      #        @ip = server.ip
      #      elsif @uri_original.host =~ /dc\d+\.4shared\.com/
      #        server = ServerFS.new(@uri_original.host.scan(/\d+/)[0].to_i)
      #        @ip = server.ip
      #      else
      raise
      #      end
    end
  end
  def <=>(object)
    return self.id_link <=> object.id_link
  end
  def retry_
    #    @tentativas += 1
    if @tentativas > @max_tentativas
      @id_status = Status::OFFLINE
      @testado = true
      update_db
      return Status::OFFLINE
    end
    sleep 1
  end
  def http_valid?
    unless @link =~ /http:\/\/\S+\/.+/
      Verbose.to_log "ERRO: Sintaxe do link inválido. Evitado."
      @id_status = Status::OFFLINE
      @testado = true
      @data_inicio = StrTime.timestamp Time.now
      update_db
      false
    end
    true
  end
  def retry?
    case @id_status
    when Status::BAIXADO
      false
    when Status::OFFLINE
      Historico.to_log("O arquivo está offline.")
      false
    else
      Core.falhou(3)
      @tentativas += 1
      true
    end
  end
  def download
    wait = Time.local(0) + @waittime
    Verbose.to_debug(wait.strftime("Contador identificado: %Hh %Mm %Ss."))
    Core.contador(@waittime, "O download iniciará em %Hh %Mm %Ss.")

    Verbose.to_log("Baixando: #{@downloadlink}")
    time_inicio = Time.now
    @data_inicio = StrTime.timestamp time_inicio
    @id_status = Status::BAIXANDO
    update_db
    ## Download com curl
    baixou = system("curl -LOC - \"#{@downloadlink}\"")
    time_fim = Time.now
    @data_fim = StrTime.timestamp time_fim
    duracao = Time.local(0) + (time_fim - time_inicio)
    duracao_str = duracao.strftime("%Hh %Mm %Ss")
    if baixou
      Verbose.to_log("D. link concluído com sucesso em #{duracao_str}.")
      Verbose.to_log("Velocidade média do link foi de #{sprintf("%.2f KB/s", @tamanho.to_i/(time_fim - time_inicio))}.")
      @id_status = Status::BAIXADO
      @completado = true
    else
      Verbose.to_log("Download do link falhou com #{duracao_str} decorridos.")
      @id_status = Status::TENTANDO
    end
    update_db
  end
  def self.select_full
    sql = "SELECT * FROM rs.link "
    rst = Banco.instance.db_connect.execute(sql)
    lista = Array.new
    current_link = nil
    begin
      rst.fetch do |row|
        begin
          current_link = row["link"].strip
        rescue URI::InvalidURIError
          Historico.to_log "URI inválido, pulando link."
          current_link = nil
        end
        lista.push current_link
      end
      rst.finish
      Banco.instance.db_disconnect
      lista.delete_if { |l| l == [] or l == nil }
      if lista == []
        nil
      else
        lista.sort
      end
    rescue Exception => e
      Historico.to_log "Houve erro => #{e}"
      sleep 1
      return nil
    end
  end
end