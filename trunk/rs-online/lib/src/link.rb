# To change this template, choose Tools | Templates
# and open the template in the editor.

class Link
  attr_writer :id_link, :link, :id_pacote, :completado, :tamanho, :id_status
  attr_reader :id_link, :link, :id_pacote, :completado, :tamanho, :id_status

  def initialize(id_link, link, id_pacote, id_status)
    @id_link = id_link
    @link = link
    @id_pacote = id_pacote
    @id_status = id_status
  end

  def <=>(object)
    return self.id_link <=> object.id_link
  end
end
