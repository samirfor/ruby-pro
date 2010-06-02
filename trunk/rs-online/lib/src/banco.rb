require 'dbi'
require 'src/pacote'
require "src/historico"
require 'src/link'
require "src/timestamp"
require "singleton"

class Banco
  include Singleton

  attr_accessor :conn

  def initialize
    self
  end

  # Gera linhas de log
  def to_log texto
    puts texto
    h = Historico.new(texto)
    h.save
  end

  # Ve o endereço do banco
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

  # Faz o singleton
  def db_connect
    if @conn.nil?
      get_conn
    end
    return @conn
  end

  # Faz a conexão com o banco de dados.
  def get_conn
    begin
      database = "postgres"
      password = "postgres"
      hostname = get_host_db
      port = 5432
      @conn = DBI.connect("DBI:Pg:dbname=#{database};host=#{hostname};port=#{port}", database, password)
    rescue DBI::DatabaseError => e
      puts "Ocorreu erro ao se conectar no banco de dados.\nStack do erro: #{e.err} #{e.errstr} SQLSTATE: #{e.state}"
      sleep 5
    end
  end

  # Disconecta-se do banco de dados.
  def db_disconnect
    begin
      @conn.disconnect
      @conn = nil
    rescue DBI::DatabaseError => e
      puts "Ocorreu erro ao se disconectar no banco de dados.\nStack do erro: #{e.err} #{e.errstr} SQLSTATE: #{e.state}"
      sleep 5
    end
  end

  # Captura os pacotes que estão para ser baixado com exceção de um, o qual
  # é passado como parâmetro.
  # Retorno: Objeto Pacote
  def select_pacotes_pendetes_teste id_pacote_excecao
    sql = "SELECT id, nome, MAX(prioridade) AS prioridade_max " +
      "FROM rs.pacote WHERE completado = 'false' AND problema = 'false' " +
      "AND id != ? GROUP BY id, nome, prioridade " +
      "ORDER BY prioridade desc, id desc"
    db_connect
    rst = @conn.execute(sql, id_pacote_excecao)
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
    db_disconnect
    return pacotes
  end

  def select_lista_pacotes mostrar
    sql = "SELECT * FROM rs.pacote WHERE mostrar = ? "
    db_connect
    rst = @conn.execute(sql, mostrar)
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
    db_disconnect
    return pacotes
  end

  def select_full_links
    sql = "SELECT * FROM rs.link "
    db_connect
    rst = @conn.execute(sql)
    lista = Array.new
    link = nil
    begin
      rst.fetch do |row|
        begin
          link = row["link"].strip
        rescue URI::InvalidURIError
          to_log "URI inválido, pulando link."
          link = nil
        end
        lista.push link
      end
      rst.finish
      db_disconnect
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
    sql += "WHERE l.id_pacote = p.id AND p.id = ? "
    db_connect
    rst = @conn.execute(sql, id_pacote)
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
      db_disconnect
      lista.sort
    rescue Exception => e
      to_log "Houve erro => #{e}"
      sleep 2
      return nil
    end
  end

  # Verifica a quantidade de pacotes e a quantidade de pacotes baixado.
  # O retorno é a diferença entre as respectivas quantidades.
  def select_remaining_links id_pacote
    sql = "SELECT count(id_link) FROM rs.link WHERE id_pacote = ? "
    db_connect
    rst = @conn.execute(sql, id_pacote)
    count_pacotes = rst.fetch_all[0].clone
    rst.finish

    sql = "SELECT count(id_link) FROM rs.link WHERE id_pacote = ? AND id_status = 1 "
    rst = @conn.execute(sql, id_pacote)
    count_baixados = rst.fetch_all[0].clone
    rst.finish
    db_disconnect

    return count_pacotes - count_baixados
  end

  def select_prioridade
    sql = "SELECT * FROM rs.prioridade"
    rst = Banco.instance.db_connect.execute(sql)
    array = rst.fetch_all[0].clone
    rst.finish
    Banco.instance.db_disconnect
    array.sort
  end

end
