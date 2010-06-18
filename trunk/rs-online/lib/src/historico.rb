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

  ### No banco
  #
  #  id bigserial NOT NULL,
  #  data character varying(50) NOT NULL,
  #  processo character varying(10),
  #  mensagem character varying(300) NOT NULL,

  # Método estático
  def self.select_top limit
    sql = "SELECT * FROM rs.historico ORDER BY id desc LIMIT ? "
    rst = Banco.instance.db_connect.execute(sql, limit)
    historicos = Array.new
    rst.fetch do |row|
      historico = Historico.new(row["mensagem"])
      historico.data = row["data"]
      historico.id = row["id"]
      historico.processo = row["processo"]
      historicos << historico
    end
    rst.finish
    Banco.instance.db_disconnect
    historicos
  end

  def self.to_log msg
    puts msg
    h = Historico.new(msg)
    h.save
  end
end