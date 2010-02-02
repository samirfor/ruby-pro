# To change this template, choose Tools | Templates
# and open the template in the editor.

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
  hash = Hash.new
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  sql = "SELECT l.link, l.id_link FROM rs.pacote p, rs.link l WHERE p.completado = 'false' LIMIT 1"
  rst = conn.execute(sql)
  rst.each do |row|
    hash[row["id_link"]] = row["link"]
  end
  rst.finish
  conn.disconnect
  hash
end

def select_lista_links(id_pacote)
  conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
  sql = "SELECT * FROM rs.link WHERE id_pacote = #{id_pacote}"
  rst = conn.execute(sql)
end