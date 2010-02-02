# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'dbi'

def update_link_completado(id_link)
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  sql = "UPDATE rs.link SET completado = 'true' WHERE id_link = #{id_link}"
  conn.do(sql)
  conn.disconnect
end

def update_pacote_completado(id_pacote)
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  sql = "UPDATE rs.pacote SET completado = 'true' WHERE id = #{id_pacote}"
  conn.do(sql)
  conn.disconnect
end

def update_data_fim(data, id_pacote)
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  sql = "UPDATE rs.pacote SET data_fim = '#{data}' WHERE id = #{id_pacote}"
  conn.do(sql)
  conn.disconnect
end

# --- RETORNA TODOS OS LINKS DE UM DETERMINADO PACOTE. [ HASH ]
def select_pacote_pendente
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  sql = "SELECT id FROM rs.pacote WHERE completado = 'false' LIMIT 1"
  rst = conn.execute(sql)
  id_pacote = rst.fetch[0]
  rst.finish
  conn.disconnect
  id_pacote
end

def select_lista_links(id_pacote)
  hash = Hash.new
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  sql = "SELECT l.link, l.id_link FROM rs.pacote p, rs.link l " +
    "WHERE l.id_pacote = p.id AND p.id = #{id_pacote}"
  rst = conn.execute(sql)
  rst.fetch do |row|
    hash[row["id_link"]] = row["link"]
  end
  hash
end