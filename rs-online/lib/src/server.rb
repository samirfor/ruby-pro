require "src/database"
require 'net/http'
require 'socket'

class Server
  attr_accessor :id, :ip, :data

  def initialize id
    @id = id
    unless is_exist?
      to_debug "Servidor não registrado. Registrando..."
      generator
      insert_db
    else
      # Se o host estiver cadastrado no BD, apenas faz o SELECT.
      to_debug "Servidor registrado. Evitando resolução de nome."
      select_db
    end
  end

  def generator
    @data = Time.now
    @ip = IPSocket.getaddress "rs#{@id}.rapidshare.com"
  end

  def timestamp time
    time.strftime("%Y/%m/%d %H:%M:%S")
  end

  def update_db
    sql = "UPDATE rs.servidores SET "
    sql += "data_modificacao = '#{timestamp(@data)}', " unless @data == nil
    sql += "ip = '#{@ip}' "
    sql += "WHERE id = #{@id}"
    db_statement_do(sql)
  end

  def select_db
=begin
  id bigserial NOT NULL,
  ip inet NOT NULL,
  data_modificacao timestamp without time zone
=end
    sql = "SELECT * FROM rs.servidores WHERE id = #{@id}"
    db = db_statement_execute(sql)
    rst = db[0]
    conn = db[1]
    begin
      server = rst.fetch_all[0]
    rescue Exception => e
      to_log "Erro do fetch"
      raise
    end
    @ip = server["ip"]
    @data = server["data_modificacao"].to_time
    rst.finish
    db_disconnect(conn)
  end

  def insert_db
    sql = "INSERT INTO rs.servidores (id, ip, data_modificacao) "
    sql += "VALUES (#{@id}, '#{@ip}', '#{timestamp(@data)}')"
    db_statement_do(sql)
  end

  def is_exist?
    sql = "SELECT * FROM rs.servidores WHERE id = #{@id}"
    db = db_statement_execute(sql)
    rst = db[0]
    conn = db[1]
    begin
      if rst.fetch_all == [] or rst.fetch_all == nil
        return false
      else
        return true
      end
    rescue Exception => ex
      to_log "Erro no fetch_all. Função is_exist?"
      return false
    end
  end
end
