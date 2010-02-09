# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'dbi'
require "src/historico"
require "src/database"

class HistoricoDao
  def initialize

  end
  
  def find_all()
    list = Array.new
    sql = "SELECT * FROM rs.historico ORDER BY data "
    
    db = db_statement_execute(sql)
    rst = db[0]
    conn = db[1]
    rst.fetch do |row|
      historico = Historico::new(row["id"], row["data"], row["processo"], row["mensagem"])
      p historico
      list.push(historico)
    end
    rst.finish
    db_disconnect(conn)
    return list
  end
end