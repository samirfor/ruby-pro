module Status
  BAIXADO = 1
  OFFLINE = 2
  ONLINE = 3
  BAIXANDO = 4
  AGUARDANDO = 5
  INTERROMPIDO = 6
  TENTANDO = 7
  TESTANDO = 8
end

#require "src/banco"
#
#class Status
#  attr_accessor :BAIXADO, :OFFLINE, :ONLINE, :BAIXANDO, :AGUARDANDO, \
#    :INTERROMPIDO, :TESTANDO, :TENTANDO
#
#  def initialize
#    @BAIXADO = 1
#    @OFFLINE = 2
#    @ONLINE = 3
#    @BAIXANDO = 4
#    @AGUARDANDO = 5
#    @INTERROMPIDO = 6
#    @TENTANDO = 7
#    @TESTANDO = 8
#  end
#
#  # Captura os dados da tabela status
#  def select
#    sql = "SELECT * FROM rs.status"
#    rst = Banco.instance.db_connect.execute(sql)
#    array = rst.fetch_all.clone
#    rst.finish
#    Banco.instance.db_disconnect
#    array = array.sort
#    array.each do |status|
#      id = status[0]
#      descricao = status[1]
#      case descricao
#      when "baixado"
#        @BAIXADO = id
#      when "offline"
#        @OFFLINE = id
#      when "online"
#        @ONLINE = id
#      when "baixado"
#        @BAIXADO = id
#      when "baixando"
#        @BAIXANDO = id
#      when "aguardando"
#        @AGUARDANDO = id
#      when "interrompido"
#        @INTERROMPIDO = id
#      when "testando"
#        @TESTANDO = id
#      when "tentando"
#        @TENTANDO = id
#      end
#    end
#  end
#end
