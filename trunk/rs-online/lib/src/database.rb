# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'dbi'

def db_connect
  begin
    DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  rescue DBI::DatabaseError => e
    to_log "Ocorreu erro ao se conectar no banco de dados."
    to_log "Código do erro: #{e.err}"
    to_log "#{e.errstr}"
    to_log "SQLSTATE: #{e.state}"
  end
end

def db_statement_execute(sql)
  begin
    conn = db_connect
    rst = conn.execute(sql)
    retorno = Array.new
    retorno.push rst
    retorno.push conn
    retorno
  rescue DBI::DatabaseError => e
    to_log "Ocorreu erro consultando o banco de dados."
    to_log "Código do erro: #{e.err}"
    to_log "#{e.errstr}"
    to_log "SQLSTATE: #{e.state}"
  end
end

def db_statement_do(sql)
  begin
    conn = db_connect
    conn.do(sql)
    db_disconnect(conn)
  rescue DBI::DatabaseError => e
    to_log "Ocorreu erro ao modificar o banco de dados."
    to_log "Código do erro: #{e.err}"
    to_log "#{e.errstr}"
    to_log "SQLSTATE: #{e.state}"
  end
end

def db_disconnect(conn)
  begin
    conn.disconnect
  rescue DBI::DatabaseError => e
    to_log "Ocorreu na disconexão do banco de dados."
    to_log "Código do erro: #{e.err}"
    to_log "#{e.errstr}"
    to_log "SQLSTATE: #{e.state}"
  end
end


def update_status_link_tamanho id_link, tamanho, id_status
  sql = "UPDATE rs.link SET id_status = #{id_status}, tamanho = #{tamanho} WHERE id_link = #{id_link}"
  db_statement_do(sql)
end

def update_status_link id_link, id_status
  sql = "UPDATE rs.link SET id_status = #{id_status} WHERE id_link = #{id_link}"
  db_statement_do(sql)
end

def update_pacote_completado data, id_pacote
  sql = "UPDATE rs.pacote SET data_fim = '#{data}', completado = 'true' WHERE id = #{id_pacote}"
  db_statement_do(sql)
end

def update_data_inicio_link id_link, data
  sql = "UPDATE rs.link SET data_inicio = '#{data}' WHERE id_link = #{id_link}"
  db_statement_do(sql)
end

def update_link_completado id_link, data, id_status
  sql = "UPDATE rs.link SET data_fim = '#{data}', completado = 'true', id_status = #{id_status} WHERE id_link = #{id_link}"
  db_statement_do(sql)
end

def update_pacote_problema id_pacote
  sql = "UPDATE rs.pacote SET problema = 'true' WHERE id = #{id_pacote}"
  db_statement_do(sql)
end

# --- Retorna o pacote a ser baixado mais prioritário e mais recente.
def select_pacote_pendente
  sql = "SELECT id, nome, MAX(prioridade) AS prioridade_max " +
    "FROM rs.pacote WHERE completado = 'false' AND problema = 'false' " +
    "GROUP BY id, nome, prioridade ORDER BY prioridade desc, id desc LIMIT 1"
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  begin
    id_pacote = rst.fetch[0]
  rescue Exception => err
    puts "Erro no fetch"
    puts err
    id_pacote = nil
  end
  rst.finish
  db_disconnect(conn)
  id_pacote
end

def select_lista_links(id_pacote)
  array = Array.new
  sql = "SELECT l.link, l.id_link, l.id_pacote, l.id_status FROM rs.pacote p, rs.link l " +
    "WHERE l.id_pacote = p.id AND p.id = #{id_pacote} AND l.completado = 'false'"
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  rst.fetch do |row|
    array.push Link.new(row["id_link"], row["link"], row["id_pacote"], row["id_status"])
  end
  rst.finish
  db_disconnect(conn)
  array.sort
end

def select_status_links id_pacote
  sql = "SELECT count(id_link) FROM rs.link WHERE id_pacote = #{id_pacote} "
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  count_pacotes = rst.fetch[0]
  rst.finish
  db_disconnect(conn)

  sql = "SELECT count(id_link) FROM rs.link WHERE id_pacote = #{id_pacote} AND id_status = 1 "
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  count_baixados = rst.fetch[0]
  rst.finish
  db_disconnect(conn)

  return count_pacotes - count_baixados
end

def save_records(texto)
  # formatar hora
  tempo = Time.new.strftime("%d/%m/%Y %H:%M:%S")
  # processo
  processo = Process.pid.to_s
  sql = "INSERT INTO rs.historico (data, processo, mensagem) values ('#{tempo}', '#{processo}', '#{texto}')"
  db_statement_do(sql)
end