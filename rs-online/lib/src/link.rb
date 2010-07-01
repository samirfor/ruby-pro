require 'net/http'
require 'socket'
require "uri"
require "httpclient" # gem install httpclient
require "src/status"
require "src/banco"

class Link
  attr_reader :link, :uri_original, :max_tentativas
  attr_accessor :uri_parsed, :id_link, :id_pacote, :completado, :tamanho, \
    :id_status, :tentativas, :data_inicio, :data_fim, :testado, :waittime, \
    :downloadlink, :filename, :retry

  def initialize link
    @link = link.strip
    @uri_original = URI.parse link
    @id_link = nil
    set_ip
    @tentativas = 0
    @max_tentativas = 10
    @completado = false
    @tamanho = 0
    @id_status = nil
    @data_inicio = nil
    @data_fim = nil
    @testado = false
    @waittime = 0
    @downloadlink = nil
    @filename = nil
    @retry = false
  end

  def get_body
    begin
      http = HTTPClient.new
      #    http.timeout_scheduler 15 #segundos
      begin
        response = http.get(@uri_parsed)
        unless response.header.status_code == 200
          Verbose.to_log "Não foi possível carregar a página."
          Verbose.to_log "#{response.header.status_code} - #{response.header.reason_phrase}"
          false if retry_ == Status::OFFLINE
        end
      end while response.header.status_code != 200
      response.body.content
    rescue Interrupt
      interrupt
    end
  end

  def interrupt
    @data_fim = Time.now
    @completado = false
    @id_status = Status::INTERROMPIDO
    update_db
  end

  # Escreve os dados no BD.
  def update_db
    begin
      a_params = {
        :tamanho => @tamanho,
        :testado => @testado,
        :completado => @completado,
        :data_inicio => @data_inicio,
        :data_fim => @data_fim,
        :filename => @filename,
        :id_status => @id_status,
        :id_link => @id_link
      }
      a_params.delete_if { |key, val| val == nil or val == "" or val == [] }

      sql = "UPDATE rs.link SET "
      a_params.each_key do |key|
        sql += "#{key} = ? , "
      end
      # FIXME testar link update_db
      # DEPRECATED
      #      @tamanho ? sql += "tamanho = '#{@tamanho}', " : sql += "tamanho = NULL, "
      #      @testado != nil ? sql += "testado = '#{@testado}', " : sql += "testado = DEFAULT, "
      #      @completado != nil ? sql += "completado = '#{@completado}', " : sql += "completado = DEFAULT, "
      #      @data_inicio ? sql += "data_inicio = '#{StrTime.timestamp(@data_inicio)}', " : sql += "data_inicio = NULL, "
      #      @data_fim ? sql += "data_fim = '#{StrTime.timestamp(@data_fim)}', " : sql += "data_fim = NULL, "
      #      @filename ? sql += "filename = '#{@filename}', " : sql += "filename = NULL, "
      sql += "id_status = ? WHERE id_link = ? "
      Banco.instance.db_connect.do(sql, *a_params.values)
    rescue Exception => e
      Verbose.to_log("Erro ao atualizar link: #{e}")
      sleep 1
    end
  end

  def reset
    @tamanho = nil
    @testado = false
    @data_inicio = nil
    @data_fim = nil
    @completado = false
    update_db
  end

  # Traduz hostname da URL para ip.
  # Retorno: String IP
  def set_ip
    begin
      ip = Resolv::DNS.new
      ip = ip.getaddress(@uri_original.host)
      @uri_parsed = @uri_original.clone
      @uri_parsed.host = ip.to_s
    rescue Exception
      raise
    end
  end
  
  def <=>(object)
    return self.id_link <=> object.id_link
  end

  def retry_
    @tentativas += 1
    if @tentativas > @max_tentativas
      @id_status = Status::ERRO
      @testado = true
      update_db
      false
    end
    # sleep 1
    true
  end

  def http_valid?
    unless @link =~ /http:\/\/\S+\/.+/
      Verbose.to_log "ERRO: Sintaxe do link inválido. Evitado."
      @id_status = Status::ERRO
      @testado = true
      @data_inicio = Time.now
      update_db
      false
    end
    true
  end

  def download
    begin
      wait = Time.local(0) + @waittime
      Verbose.to_debug(wait.strftime("Contador identificado: %Hh %Mm %Ss."))
      Core.contador(@waittime, "O download iniciará em %Hh %Mm %Ss.")

      Verbose.to_log("Baixando: #{@downloadlink}")
      time_inicio = Time.now
      @data_inicio = time_inicio
      @id_status = Status::BAIXANDO
      update_db
      ## Download com curl
      #    config = RsConfig.parse("/home/#{`whoami`.chomp}/rs-online.conf")
      #    baixou = system("cd #{config[:local]}; curl -LOC - \"#{@downloadlink}\"")
      baixou = system("curl -LOC - \"#{@downloadlink}\"")
      time_fim = Time.now
      @data_fim = time_fim
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
    rescue Interrupt
      interrupt
    end
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
          Verbose.to_log "URI inválido, pulando link."
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
      Verbose.to_log "Houve erro => #{e}"
      sleep 1
      return nil
    end
  end
end
