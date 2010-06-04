# Deprecated file!
# Deprecated file!
# Deprecated file!
# Deprecated file!
# Use banco.rb

require 'dbi'
require 'src/pacote'
require 'src/link'
require "singleton"

# Gera linhas de log
def to_log texto
  save_historico texto
  puts texto
end

def get_host_db
  hostname = `hostname`.chomp
  if hostname == "samir-multi"
    return "localhost"
  elsif hostname == "samir-home"
    return "localhost"
  else
    return "10.50.0.141"
  end
end

# Faz a conexão com o banco de dados.
def db_connect
  begin
    database = "postgres"
    password = "postgres"
    hostname = get_host_db
    port = 5432
    DBI.connect("DBI:Pg:dbname=#{database};host=#{hostname};port=#{port}", database, password)
  rescue DBI::DatabaseError => e
    to_log "Ocorreu erro ao se conectar no banco de dados.\nStack do erro: #{e.err} #{e.errstr} SQLSTATE: #{e.state}"
    sleep 5
  end
end

# Executa algum query SQL e retorna os resultados
def db_statement_execute(sql)
  begin
    conn = db_connect
    rst = conn.execute(sql)
    retorno = Array.new
    retorno.push rst
    retorno.push conn
    retorno
  rescue DBI::DatabaseError => e
    to_log "Ocorreu erro ao executar uma SQL.\nStack do erro: #{e.err} #{e.errstr} SQLSTATE: #{e.state}"
    sleep 5
  end
end

# Executa alguma ação sem retorno, como o UPDATE
def db_statement_do(sql)
  begin
    conn = db_connect
    conn.do(sql)
    db_disconnect(conn)
  rescue DBI::DatabaseError => e
    to_log "Ocorreu erro ao consultar o BD.\nStack do erro: #{e.err} #{e.errstr} SQLSTATE: #{e.state}"
    sleep 5
  end
end

# Disconecta-se do banco de dados.
def db_disconnect(conn)
  begin
    conn.disconnect
  rescue DBI::DatabaseError => e
    to_log "Ocorreu erro ao se disconectar no banco de dados.\nStack do erro: #{e.err} #{e.errstr} SQLSTATE: #{e.state}"
    sleep 5
  end
end

def timestamp time
  time.strftime("%Y/%m/%d %H:%M:%S")
end

def select_count_links id_pacote
  sql = "SELECT count(id_link) FROM rs.link WHERE id_pacote = #{id_pacote} "
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  count_total = rst.fetch[0]
  rst.finish
  db_disconnect(conn)

  sql = "SELECT count(id_link) FROM rs.link WHERE id_pacote = #{id_pacote} AND id_status = 1 "
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  count_baixados = rst.fetch[0]
  rst.finish
  db_disconnect(conn)

  count = []
  count.push count_baixados
  count.push count_total
  count
end

# Retorna o pacote a ser baixado mais prioritário e mais recente.
# Retorno: Objeto Pacote
def select_pacote_pendente
  sql = "SELECT id, nome, MAX(prioridade) AS prioridade_max " +
    "FROM rs.pacote WHERE completado = 'false' AND problema = 'false' " +
    "GROUP BY id, nome, prioridade ORDER BY prioridade desc, id desc LIMIT 1"
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  pacote = nil
  begin
    rst.fetch do |row|
      pacote = Pacote.new(row["nome"])
      pacote.id_pacote = row["id"]
      pacote.prioridade = row["prioridade_max"]
    end
  rescue Exception => err
    puts "Erro no fetch"
    puts err
    pacote = nil
  end
  rst.finish
  db_disconnect(conn)
  pacote
end

# Captura no BD um pacote específico.
def select_pacote(id)
  sql = "SELECT * FROM rs.pacote WHERE id = #{id}"
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
=begin
  id bigserial NOT NULL,
  nome character varying(100) NOT NULL,
  completado boolean DEFAULT false,
  mostrar boolean DEFAULT true,
  problema boolean DEFAULT false,
  data_inicio timestamp without time zone DEFAULT now(),
  data_fim timestamp without time zone,
  senha character varying(50),
  prioridade integer DEFAULT 3,
  tamanho integer,
=end
  pacote = nil
  begin
    rst.fetch do |row|
      pacote = Pacote.new row["nome"]
      pacote.id_pacote = row["id"]
      pacote.completado = row["completado"]
      pacote.mostrar = row["mostrar"]
      pacote.problema = row["problema"]
      pacote.data_inicio = row["data_inicio"]
      pacote.data_fim = row["data_fim"]
      pacote.senha = row["senha"]
      pacote.prioridade = row["prioridade"]
      pacote.tamanho = row["tamanho"]
      pacote.descricao = row["descricao"]
      pacote.url_fonte = row["url_fonte"]
      pacote.legenda = row["legenda"]
    end
  rescue Exception => err
    puts "Erro no fetch"
    puts err
    pacote = nil
  end
  rst.finish
  db_disconnect(conn)
  return pacote
end

# Captura os pacotes que estão para ser baixado com exceção de um, o qual
# é passado como parâmetro.
# Retorno: Objeto Pacote
def select_pacotes_pendetes_teste id_pacote_excecao
  sql = "SELECT id, nome, MAX(prioridade) AS prioridade_max " +
    "FROM rs.pacote WHERE completado = 'false' AND problema = 'false' " +
    "AND id != #{id_pacote_excecao} " +
    "GROUP BY id, nome, prioridade " +
    "ORDER BY prioridade desc, id desc"
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  pacotes = Array.new
  pacote = nil
  begin
    rst.fetch do |row|
      pacote = Pacote.new(row["nome"])
      pacote.id_pacote = row["id"]
      pacote.prioridade = row["prioridade_max"]
      pacotes.push pacote
    end
  rescue Exception => err
    puts "Erro no fetch"
    puts err
    pacotes = nil
  end
  rst.finish
  db_disconnect(conn)
  return pacotes
end

# Captura a lista de links.
# Retorna um Array de Objetos Link
def select_lista_links id_pacote
  if id_pacote == nil or id_pacote == ""
    return nil
  end
=begin
  id_link bigserial NOT NULL,
  id_pacote integer NOT NULL,
  link character varying(300) NOT NULL,
  completado boolean DEFAULT false,
  tamanho integer,
  id_status integer NOT NULL DEFAULT 5,
  data_inicio timestamp without time zone,
  data_fim timestamp without time zone,
  testado boolean NOT NULL DEFAULT false,
=end
  sql = "SELECT l.id_link, l.id_pacote, l.link, l.completado, l.tamanho, "
  sql += "l.id_status, l.data_inicio, l.data_fim, l.testado "
  sql += "FROM rs.pacote p, rs.link l "
  sql += "WHERE l.id_pacote = p.id AND p.id = #{id_pacote}"
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  lista = Array.new
  link = nil
  begin
    rst.fetch do |row|
      link = Link.new(row["link"])
      link.id_link = row["id_link"]
      link.id_pacote = row["id_pacote"]
      link.completado = row["completado"]
      link.tamanho = row["tamanho"]
      link.id_status = row["id_status"]
      link.testado = row["testado"]
      link.data_inicio = row["data_inicio"]
      link.data_fim = row["data_fim"]
      lista.push link
    end
    rst.finish
    db_disconnect(conn)
    lista.sort
  rescue Exception => e
    to_log "Houve erro => #{e}"
    sleep 2
    return nil
  end
end

def select_lista_pacotes mostrar
  sql = "SELECT * FROM rs.pacote WHERE mostrar = '#{mostrar}' "
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  pacotes = Array.new
  pacote = nil
  begin
    rst.fetch do |row|
      pacote = Pacote.new(row["nome"])
      pacote.id_pacote = row["id"]
      pacote.completado = row["completado"]
      pacote.mostrar = row["mostrar"]
      pacote.problema = row["problema"]
      pacote.data_inicio = row["data_inicio"]
      pacote.data_fim = row["data_fim"]
      pacote.senha = row["senha"]
      pacote.prioridade = row["prioridade"]
      pacote.tamanho = row["tamanho"]
      pacote.descricao = row["descricao"]
      pacote.url_fonte = row["url_fonte"]
      pacote.legenda = row["legenda"]
      pacotes.push pacote
    end
  rescue Exception => err
    puts "Erro no fetch"
    puts err
    pacotes = nil
  end
  rst.finish
  db_disconnect(conn)
  return pacotes
end

# Verifica a quantidade de pacotes e a quantidade de pacotes baixado.
# O retorno é a diferença entre as respectivas quantidades.
def select_count_remaining_links id_pacote
  sql = "SELECT count(id_link) FROM rs.link WHERE id_pacote = #{id_pacote} "
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  count_pacotes = rst.fetch[0]
  rst.finish
  db_disconnect(conn)

  sql = "SELECT count(id_link) FROM rs.link WHERE id_pacote = #{id_pacote} AND id_status = 1 "
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  count_baixados = rst.fetch[0]
  rst.finish
  db_disconnect(conn)

  return count_pacotes - count_baixados
end

# Insere o log no banco de dados
def save_historico texto
  # formatar hora
  tempo = Time.new.strftime("%d/%m/%Y %H:%M:%S")
  # processo
  processo = Process.pid.to_s
  sql = "INSERT INTO rs.historico (data, processo, mensagem) values ('#{tempo}', '#{processo}', '#{texto}')"
  db_statement_do(sql)
end

# Captura os dados da tabela prioridade
def select_prioridade
  sql = "SELECT * FROM rs.prioridade"
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  array = rst.fetch_all.clone
  rst.finish
  db_disconnect(conn)
  array.sort
end

def select_historico
  sql = "SELECT * FROM rs.historico ORDER BY id desc LIMIT 100 "
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  historicos = Array.new
  historico = nil
  rst.fetch do |row|
    historico = Historico.new(row["id"], row["data"], row["processo"], row["mensagem"])
    historicos.push historico
  end
  rst.finish
  db_disconnect(conn)
  historicos
end

def select_servico id
  sql = "SELECT id, descricao FROM rs.servico WHERE id = #{id}"
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  id_servico = rst.fetch[0]
  rst.finish
  db_disconnect(conn)
  id_servico
end

# inserir o pacote e os links no banco
def save_pacote(pacote)
  data_inicio = Time.now
  sql = "INSERT INTO rs.pacote (nome, data_inicio, prioridade "
  sql += ", senha" unless pacote.senha == "" or pacote.senha == nil
  sql += ", descricao" unless pacote.descricao == "" or pacote.descricao == nil
  sql += ", url_fonte" unless pacote.url_fonte == "" or pacote.url_fonte == nil
  sql += ", legenda" unless pacote.legenda == "" or pacote.legenda == nil
  sql += ") VALUES ('#{pacote.nome}', '#{timestamp data_inicio}' "
  sql += ", #{pacote.prioridade}"
  sql += ", '#{pacote.senha}'" unless pacote.senha == "" or pacote.senha == nil
  sql += ", '#{pacote.descricao}'" unless pacote.descricao == "" or pacote.descricao == nil
  sql += ", '#{pacote.url_fonte}'" unless pacote.url_fonte == "" or pacote.url_fonte == nil
  sql += ", '#{pacote.legenda}'" unless pacote.legenda == "" or pacote.legenda == nil
  sql += ") RETURNING id"

  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  resultado = rst.fetch[0]
  rst.finish
  db_disconnect(conn)
  return resultado
end

def save_links(links, id_pacote)
  retorno = []
  links.each do |line|
    sql = "INSERT INTO rs.link (id_pacote, link) VALUES (#{id_pacote}, '#{line}') RETURNING id_link"
    db = db_statement_execute(sql)
    rst = db[0]
    conn = db[1]
    retorno.push rst.fetch[0]
    rst.finish
    db_disconnect(conn)
  end
  return retorno
end

def select_full_links
  sql = "SELECT * FROM rs.link "
  db = db_statement_execute(sql)
  rst = db[0]
  conn = db[1]
  lista = Array.new
  link = nil
  begin
    rst.fetch do |row|
      begin
        link = row["link"].strip
      rescue URI::InvalidURIError => i
        to_log "URI inválido, pulando link."
        link = nil
      end
      #      p row
      #      link = Link.new(row["link"])
      #      link.id_link = row["id_link"]
      #      link.id_pacote = row["id_pacote"]
      #      link.completado = row["completado"]
      #      link.tamanho = row["tamanho"]
      #      link.id_status = row["id_status"]
      #      link.testado = row["testado"]
      #      link.data_inicio = row["data_inicio"]
      #      link.data_fim = row["data_fim"]
      lista.push link
    end
    rst.finish
    db_disconnect(conn)
    lista.delete_if { |l| l == [] or l == nil }
    if lista == []
      nil
    else
      lista.sort
    end
  rescue Exception => e
    to_log "Houve erro => #{e.message}"
    sleep 2
    return nil
  end
end
