require "src/celular"

class Usuario
  attr_accessor :id, :login, :senha, :nome, :celular

  def initialize id
    @id = id
    @login = nil
    @senha = nil
    @nome = nil
    @celular = nil
  end

  def get_celular ddd, numero
    @celular = Celular.new(ddd, numero)
  end
end
