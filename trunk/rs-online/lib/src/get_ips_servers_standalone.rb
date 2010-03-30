require "src/server"

for i in 1..1000
  server = Server.new(i)
  puts "Servidor rs#{i}.rapidshare.com cadastrado com ip #{server.ip}"
end