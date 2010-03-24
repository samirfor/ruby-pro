# To change this template, choose Tools | Templates
# and open the template in the editor.

class Pacote
  attr_accessor :id_pacote, :tamanho, :data, :problema, :nome, :completado, :mostrar, :prioridade, :senha, :data_inicio, :data_fim

  def initialize nome
    @nome = nome
    @tamanho = 0
    @problema = false
    @completado = false
    @data_inicio = '2000-01-01'
    @data_fim = '2000-01-01'
  end

  def update_db
    sql = "UPDATE rs.pacote SET "
    sql += "tamanho = #{@tamanho}, "
    sql += "data_fim = '#{@data_fim}', "
    sql += "completado = '#{@completado}', "
    sql += "problema = '#{@problema}' "
    sql += "WHERE id = #{@id_pacote}"
    db_statement_do(sql)
  end
end
