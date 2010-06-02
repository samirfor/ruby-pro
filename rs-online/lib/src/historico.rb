require "src/banco"

class Historico
  attr_accessor :id, :data, :processo, :mensagem

  def initialize(mensagem)
    @id = nil
    @data = nil
    @processo = nil
    @mensagem = mensagem
  end

  # Insere o log no banco de dados
  def save
    @data = Time.new.strftime("%d/%m/%Y %H:%M:%S")
    @processo = Process.pid.to_s
    sql = "INSERT INTO rs.historico (data, processo, mensagem) values (?, ?, ?)"
    Banco.instance.db_connect.do(sql, @data, @processo, @mensagem)
  end

  def select
    sql = "SELECT * FROM rs.historico ORDER BY id desc LIMIT 100 "
    rst = Banco.instance.db_connect.execute(sql)
    historicos = Array.new
    historico = nil
    rst.fetch do |row|
      historico = Historico.new(row["id"], row["data"], row["processo"], row["mensagem"])
      historicos.push historico
    end
    rst.finish
    Banco.instance.db_disconnect
    historicos
  end
end