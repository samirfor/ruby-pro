require "resolv"

class FourShared

  attr_reader :body

  def initialize body
    @body = body
  end

  def get_ticket
    begin
      ticket = @body.scan(/<a href=\"(http:\/\/[\w\.]*4shared(-china)?\.com\/get[^\;\"]*).*\" class=\".*dbtn.*\" tabindex=\"1\"/i)[0][0]
    rescue
    end
    if ticket == nil or ticket == []
      # talvez download direto
      begin
        ticket = @body.scan(/startDownload.*window\.location.*(http:\/\/.*)\"/i)[0]
      rescue
        return nil
      end
      return nil if ticket == nil or ticket == []
    end
    ticket
  end
  def file_not_found?
    if avaliable? and get_size != nil
      false
    else
      true
    end
  end
  def avaliable?
    expressao = @body.scan(/<title>4shared.com.*download.*<\/title>/i)
    if expressao == nil or expressao == []
      false
    else
      true
    end
  end

  def linkerror?
    expressao = @body.scan(/linkerror.jsp/i)
    if expressao == nil or expressao == []
      false
    else
      true
    end
  end
  def get_size
    begin
      tamanho = @body.scan(/<b>Size:<\/b><\/td>.*<.*>(.*) KB<\/td>/i)[0]
    rescue
      return nil
    end
    return nil if tamanho == nil or tamanho == []
    tamanho.delete(",").to_i
  end
  def get_downloadlink
    begin
      search = @body.scan(/id=\'divDLStart\' >.*<a href=\'(.*)\'/i)[0]
    rescue
    end
    begin
      search = @body.scan(/(\'|\")(http:\/\/dc\d+\.4shared(-china)?\.com\/download\/\d+\/.*\/.*)(\'|\")/i)[1]
    rescue
      nil
    end if search == nil
    return nil if search == []
    return search
  end
  def get_countdown
    begin
      search = @body.scan(/var c = (\d+);/)[0]
    rescue
      return 40
    end
    if search == nil or search == []
      return 40
    end
    search.to_i
  end
end
