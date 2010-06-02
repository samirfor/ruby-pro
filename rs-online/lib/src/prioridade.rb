module Prioridade
	NENHUMA = 1
  BAIXA = 2
  NORMAL = 3
  ALTA = 4
  MUITO_ALTA = 5
end

#require "src/banco"
#
#class Prioridade
#  attr_accessor :NENHUMA, :BAIXA, :NORMAL, :ALTA, :MUITO_ALTA
#
#  def initialize
#    @NENHUMA = 1
#    @BAIXA = 2
#    @NORMAL = 3
#    @ALTA = 4
#    @MUITO_ALTA = 5
#  end
#
#  # Captura os dados da tabela prioridade
#  def select
#    sql = "SELECT * FROM rs.prioridade"
#    rst = Banco.instance.db_connect.execute(sql)
#    array = rst.fetch_all.clone
#    rst.finish
#    Banco.instance.db_disconnect
#    array = array.sort
#    array.each do |prioridade|
#      id = prioridade[0]
#      descricao = prioridade[1]
#      case descricao
#      when "nenhuma"
#        @NENHUMA = id
#      when "baixa"
#        @BAIXA = id
#      when "alta"
#        @ALTA = id
#      when "muito alta"
#        @MUITO_ALTA = id
#      end
#    end
#  end
#end
