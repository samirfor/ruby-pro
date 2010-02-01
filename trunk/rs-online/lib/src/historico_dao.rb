# To change this template, choose Tools | Templates
# and open the template in the editor.
require "dbi"
require "src/historico"

class HistoricoDao
  def initialize

  end
  
  def find_all()
    list = Array.new
    conn = DBI.connect("DBI:Pg:postgres:localhost", "postgres", "postgres")
    sql = <<FIMSQL
    SELECT * FROM rs.historico ORDER BY data
FIMSQL
    rst = conn.execute(sql)
    rst.fetch do |row|
      historico = Historico::new(row["id"], row["data"], row["processo"], row["mensagem"])
      p historico
      list.push(historico)
    end
    rst.finish
    conn.disconnect
    return list
  end
end