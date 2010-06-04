require "src/timestamp"
require "rubygems"
require "shorturl"
require "src/link"

class Pacote
  attr_accessor :id_pacote, :tamanho, :problema, :nome, :completado, \
    :mostrar, :prioridade, :senha, :data_inicio, :data_fim, :descricao, \
    :url_fonte, :legenda

  def initialize nome
    @nome = nome
    @tamanho = 0
    @problema = false
    @completado = false
    @data_inicio = nil
    @data_fim = nil
    @mostrar = nil
    @senha = nil
    @descricao = nil
    @url_fonte = nil
    @legenda = nil
  end
  
  def update_db
    #    @legenda = encurta_url(@legenda)
    #    @url_fonte = encurta_url(@url_fonte)

    sql = "UPDATE rs.pacote SET "
    sql += "tamanho = #{@tamanho}, " unless @tamanho == nil
    sql += "data_fim = '#{@data_fim}', " unless @data_fim == nil
    sql += "data_inicio = '#{@data_inicio}', " unless @data_inicio == nil
    sql += "prioridade = #{@prioridade}, " unless @prioridade == nil
    sql += "completado = '#{@completado}', " unless @completado == nil
    sql += "mostrar = '#{@mostrar}', " unless @mostrar == nil
    sql += "senha = '#{@senha}', " unless @senha == nil
    sql += "descricao = '#{@descricao}', " unless @descricao == nil
    sql += "url_fonte = '#{@url_fonte}', " unless @url_fonte == nil
    sql += "legenda = '#{@legenda}', " unless @legenda == nil
    sql += "problema = '#{@problema}' "
    sql += "WHERE id = #{@id_pacote}"
    Banco.instance.db_connect.do(sql)
  end

  def encurta_url text
    return nil if text == nil
    text_original = text
    text.strip!
    if text =~ /http:\/\/.+/i and not text =~ /http:\/\/tinyurl.+/i
      return ShortURL.shorten(text, :tinyurl)
    else
      return text_original
    end
  end

  
  ######################
  ## Funções do Banco
  ######################

  def select_count_links
    sql = "SELECT count(id_link) FROM rs.link WHERE id_pacote = ? "
    rst = Banco.instance.db_connect.execute(sql, @id_pacote)
    count_total = rst.fetch_all[0]
    rst.finish

    sql = "SELECT count(id_link) FROM rs.link WHERE id_pacote = ? AND id_status = 1 "
    rst = Banco.instance.db_connect.execute(sql, @id_pacote)

    count_baixados = rst.fetch_all[0]
    rst.finish
    Banco.instance.db_disconnect

    count = []
    count.push count_baixados
    count.push count_total
    count
  end

  # Retorna o pacote a ser baixado mais prioritário e mais recente.
  # Retorno: Objeto Pacote
  def self.select_pendente
    sql = "SELECT id, nome, MAX(prioridade) AS prioridade_max " +
      "FROM rs.pacote WHERE completado = 'false' AND problema = 'false' " +
      "GROUP BY id, nome, prioridade ORDER BY prioridade desc, id desc LIMIT 1"
    begin
      rst = Banco.instance.db_connect.execute(sql)
      pacote = nil
      rst.fetch do |row|
        pacote = Pacote.new(row["nome"])
        pacote.id_pacote = row["id"]
        pacote.prioridade = row["prioridade_max"]
      end
    rescue Exception => err
      puts "Erro no fetch ou resultset: #{err}"
      nil
    end
    rst.finish
    Banco.instance.db_disconnect
    pacote
  end

  # Tras do banco o pacote com o id específico
  def select

    #  id bigserial NOT NULL,
    #  nome character varying(100) NOT NULL,
    #  completado boolean DEFAULT false,
    #  mostrar boolean DEFAULT true,
    #  problema boolean DEFAULT false,
    #  data_inicio timestamp without time zone DEFAULT now(),
    #  data_fim timestamp without time zone,
    #  senha character varying(50),
    #  prioridade integer DEFAULT 3,
    #  tamanho integer,
    #  descricao character varying(250),
    #  url_fonte character varying(200),
    #  legenda character varying(200),

    sql = "SELECT * FROM rs.pacote WHERE id = ?"
    begin
      rst = Banco.instance.db_connect.execute(sql, @id_pacote)
      if rst == nil
        raise
      end
      rst.fetch do |row|
        @nome = row["nome"]
        @completado = row["completado"]
        @mostrar = row["mostrar"]
        @problema = row["problema"]
        @data_inicio = row["data_inicio"]
        @data_fim = row["data_fim"]
        @senha = row["senha"]
        @prioridade = row["prioridade"]
        @tamanho = row["tamanho"]
        @descricao = row["descricao"]
        @url_fonte = row["url_fonte"]
        @legenda = row["legenda"]
      end
      rst.finish
    rescue Exception => err
      puts "Erro no fetch: #{err.message}\nBacktrace: #{err.backtrace.join("\n")}"
      @id_pacote = nil
    end
    Banco.instance.db_disconnect
    self
  end

  # Insere o pacote e os links no banco
  def save
    @data_inicio = Time.now
    sql = "INSERT INTO rs.pacote   \
        (nome, data_inicio, prioridade, senha, descricao, url_fonte, legenda) \
        VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING id"

    begin
      rst = Banco.instance.db_connect.execute(sql, @nome, timestamp(@data_inicio), \
          @prioridade, @senha, @descricao, @url_fonte, \
          @legenda)
    rescue Exception => e
      puts "Erro no resultset. Não foi possível salvar o pacote \"#{@nome}\"."
      puts "#{e.message}\nBacktrace: #{e.backtrace.join("\n")}"
      @id_pacote = nil
      return
    end
    if rst == nil
      puts "Resultset nulo. Não foi possível salvar o pacote \"#{@nome}\"."
      @id_pacote = nil
      return
    end
    
    begin
      @id_pacote = rst.fetch_all[0][0]
    rescue Exception => e
      puts "Erro no fetch: #{e.message}\nBacktrace: #{e.backtrace.join("\n")}"
      @id_pacote = nil
    end
    rst.finish
    Banco.instance.db_disconnect
    @id_pacote
  end

  def save_links(links)
    retorno = []
    links.each do |line|
      sql = "INSERT INTO rs.link (id_pacote, link) VALUES (?, ?) RETURNING id_link"
      begin
        rst = Banco.instance.db_connect.execute(sql, @id_pacote, line)
      rescue Exception => e
        puts "Erro no resultset: #{e.message}\nBacktrace: #{e.backtrace.join("\n")}"
        return nil
      end
      retorno.push rst.fetch_all[0][0]
      rst.finish
      Banco.instance.db_disconnect
    end
    return retorno
  end

  # Captura os pacotes que estão para ser baixado com exceção de um, o qual
  # é passado como parâmetro.
  # Retorno: Objeto Pacote
  def self.select_pacotes_pendetes_teste id_pacote
    sql = "SELECT id, nome, MAX(prioridade) AS prioridade_max " +
      "FROM rs.pacote WHERE completado = 'false' AND problema = 'false' " +
      "AND id != ? GROUP BY id, nome, prioridade " +
      "ORDER BY prioridade desc, id desc"
    rst = Banco.instance.db_connect.execute(sql, id_pacote)
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
      puts "Erro no fetch: #{err}"
      nil
    end
    rst.finish
    Banco.instance.db_disconnect
    pacotes
  end

  def self.select_lista mostrar
    sql = "SELECT * FROM rs.pacote WHERE mostrar = ? "
    begin
      rst = Banco.instance.db_connect.execute(sql, mostrar)
      pacotes = Array.new
      pacote = nil
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
    Banco.instance.db_disconnect
    return pacotes
  end
  
  # Captura a lista de links.
  # Retorna um Array de Objetos Link
  def select_links
    if @id_pacote == nil or @id_pacote == ""
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
    lista = Array.new
    link = nil
    begin
      rst = Banco.instance.db_connect.execute(sql, @id_pacote)
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
      Banco.instance.db_disconnect
      lista.sort
    rescue Exception => e
      to_log "Houve erro => #{e}"
      sleep 1
      return nil
    end
  end

  # Verifica a quantidade de pacotes e a quantidade de pacotes baixado.
  # O retorno é a diferença entre as respectivas quantidades.
  def select_count_remaining_links
    sql = "SELECT count(id_link) FROM rs.link WHERE id_pacote = ? "
    rst = Banco.instance.db_connect.execute(sql, @id_pacote)
    count_pacotes = rst.fetch_all[0].clone
    rst.finish

    sql = "SELECT count(id_link) FROM rs.link WHERE id_pacote = ? AND id_status = 1 "
    rst = @conn.execute(sql, @id_pacote)
    count_baixados = rst.fetch_all[0].clone
    rst.finish
    Banco.instance.db_disconnect

    return count_pacotes - count_baixados
  end
end
