require "src/banco"
require "src/timestamp"
require 'net/http'
require 'socket'
require "date"
require "time"

class ServerFS
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
    @data = timestamp(@data)
    @ip = IPSocket.getaddress "dc#{@id}.4shared.com"
  end

  def update_db
    sql = "UPDATE rs.servidores_fs SET "
    sql += "data_modificacao = ?, ip = ? WHERE id = ?"
    Banco.instance.db_connect.do(sql, @data, @ip, @id)
  end

  def select_db
=begin
  id bigserial NOT NULL,
  ip inet NOT NULL,
  data_modificacao timestamp without time zone
=end
    sql = "SELECT * FROM rs.servidores_fs WHERE id = ?"
    rst = Banco.instance.db_connect.execute(sql, @id)
    begin
      server = rst.fetch_all[0]
    rescue Exception
      puts "Erro do fetch"
      raise
    end
    @ip = server["ip"]
    @data = Time.parse server["data_modificacao"].to_s
    rst.finish
    Banco.instance.db_disconnect
  end

  def insert_db
    sql = "INSERT INTO rs.servidores_fs (id, ip, data_modificacao) "
    sql += "VALUES (?, ?, ?)"
    Banco.instance.db_connect.do(sql, @id, @ip, @data)
  end

  def is_exist?
    sql = "SELECT * FROM rs.servidores_fs WHERE id = ?"
    rst = Banco.instance.db_connect.execute(sql, @id)
    begin
      if rst.fetch_all == [] or rst.fetch_all == nil
        return false
      else
        return true
      end
      rst.finish
      Banco.instance.db_disconnect
    rescue Exception
      puts "Erro no fetch_all. Função is_exist?"
      return false
    end
  end
end
