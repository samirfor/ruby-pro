require "src/server"

for i in 1..995
  begin
    server = Server.new(i)
    puts "Servidor rs#{i}.rapidshare.com cadastrado com ip #{server.ip}"
  rescue Exception => ex
    sleep 1
    i += 1
  end
end