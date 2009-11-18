Class Megaupload
def start(link)
  intento=0
  name = "62f"
  while (intento < 5 && name == "62f")
    codigo = "a"
    while codigo.length != 3 and codigo.length != 0
      pagina = Net::HTTP.get URI.parse(link)
      if pagina.match("is not available") or pagina.match("This file has expired")
        puts "Arquivo não disponível ou expirado."
      end
      wsize = pagina.match(/Filesize:\<\/b\> (.*)\<\/div\>/)[1]
      if wsize.match(/MB/)
        size = wsize.match(/(\d+\.*\d*) MB/)[1].to_f*1024*1024
      else
        if wsize.match(/KB/)
          size = wsize.match(/(\d+\.*\d*) KB/)[1].to_f*1024
        end
      end
      codigo = "http://www.megaupload.com" << pagina.match("/capgen.php[?A-Z0-9a-z]+")[0])
      varis = {
        'd'=> pagina.match("\"d\" value\=\"([A-Z0-9a-z]+)\"")[1],
        'imagecode'=> pagina.match("\"imagecode\" value\=\"([A-Z0-9a-z]+)\"")[1],
        'megavar'=>pagina.match("\"megavar\" value\=\"([A-Z0-9a-z]+)\"")[1],
        'imagestring'=> codigo
      }
    end
    res = Net::HTTP.post_form(URI.parse(pagina.match("action=\"(http[^\"]+)\" targ")[1]),varis)
    file = res.body
    linktmp= file.scan(/http:\/\/www[0-9]+.megaupload.com[^"]+/)[0].split("\'")
    segundo = Math.sqrt(file.scan(/Math.sqrt\((\d+)\)/)[0][0]).to_i
    primero = file.scan(/Math.abs\(-(\d+)\)/)[0][0]
    char = file.scan(/var [a-z] = '([a-z0-9A-Z])'/)[0][0]
    link = linktmp[0] << char << segundo.to_i.chr << primero.to_i.chr << linktmp[-1]
    name = link.split("/")[-1]
    intento = intento + 1
  end
  if name == "62f"
    raise Wrongfile, "se ha bajado algo muy raro"
  end
  puts "esperando"
  sleep 45
  puts "fin espera"
  link = URI.parse(URI.escape(link))
  http2 = Net::HTTP.new(link.host, link.port)
  #               puts http2.head(link.request_uri)
  @name = name
  File.open(File.join(@tempdir,@name),"wb"){ |file|
    http2.get(link.request_uri) do |str|
      file.write str
    end
  }
end
def getcode(link)
  puts link
  return gets.chomp.upcase
end
def getmorti(link)
  puts link
  code = `ssh -o ConnectTimeout=1 -o stricthostkeychecking=no -o BatchMode=yes david@193.147.69.124 megaocr.rb #{link} 2>/dev/null`.chomp
  puts code
  return code.upcase
end