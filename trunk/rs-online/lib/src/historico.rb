# To change this template, choose Tools | Templates
# and open the template in the editor.

class Historico
  attr_writer :id, :data, :processo, :mensagem

  def initialize(id, data, processo, mensagem)
    @id = id
    @data = data
    @processo = processo
    @mensagem = mensagem
  end
end