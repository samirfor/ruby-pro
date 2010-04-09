require "src/database"

class Pacote
  attr_accessor :id_pacote, :tamanho, :problema, :nome, :completado, \
    :mostrar, :prioridade, :senha, :data_inicio, :data_fim, :descricao

  def initialize nome
    @nome = nome
    @tamanho = 0
    @problema = false
    @completado = false
    @data_inicio = nil
    @data_fim = nil
    @mostrar = nil
    @senha = nil
    @descricao = nil
  end

  def update_db
    sql = "UPDATE rs.pacote SET "
    sql += "tamanho = #{@tamanho}, " unless @tamanho == nil
    sql += "data_fim = '#{@data_fim}', " unless @data_fim == nil
    sql += "data_inicio = '#{@data_inicio}', " unless @data_inicio == nil
    sql += "prioridade = #{@prioridade}, " unless @prioridade == nil
    sql += "completado = '#{@completado}', " unless @completado == nil
    sql += "mostrar = '#{@mostrar}', " unless @mostrar == nil
    sql += "senha = '#{@senha}', " unless @senha == nil
    sql += "descricao = '#{@descricao}', " unless @descricao == nil
    sql += "problema = '#{@problema}' "
    sql += "WHERE id = #{@id_pacote}"
    db_statement_do(sql)
  end
end
