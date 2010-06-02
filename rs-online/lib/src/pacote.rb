require "src/timestamp"
require "rubygems"
require "shorturl"
require "src/banco"

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
    @legenda = encurta_url(@legenda)
    @url_fonte = encurta_url(@url_fonte)

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
    count_total = rst.fetch_all.clone
    rst.finish

    sql = "SELECT count(id_link) FROM rs.link WHERE id_pacote = ? AND id_status = 1 "
    rst = Banco.instance.db_connect.execute(sql, @id_pacote)

    count_baixados = rst.fetch_all.clone
    rst.finish
    Banco.instance.db_disconnect

    count = []
    count.push count_baixados
    count.push count_total
    count
  end

  # Retorna o pacote a ser baixado mais prioritário e mais recente.
  # Retorno: Objeto Pacote
  def select_pendente
    sql = "SELECT id, nome, MAX(prioridade) AS prioridade_max " +
      "FROM rs.pacote WHERE completado = 'false' AND problema = 'false' " +
      "GROUP BY id, nome, prioridade ORDER BY prioridade desc, id desc LIMIT 1"
    rst = Banco.instance.db_connect.execute(sql)
    begin
      rst.fetch do |row|
        @nome = row["nome"]
        @id_pacote = row["id"]
        @prioridade = row["prioridade_max"]
      end
    rescue Exception => err
      puts "Erro no fetch"
      puts err
      @id_pacote = nil
    end
    rst.finish
    Banco.instance.db_disconnect
  end

  # Tras do banco o pacote com o id específico
  def select
    sql = "SELECT * FROM rs.pacote WHERE id = ?"
    rst = Banco.instance.db_connect.execute(sql, @id)
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
    begin
      rst.fetch do |row|
        @nome = row["nome"]
        @id_pacote = row["id"]
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
    rescue Exception => err
      puts "Erro no fetch"
      puts err
      @id_pacote = nil
    end
    rst.finish
    Banco.instance.db_disconnect
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
    rescue
      puts "Não foi possível salvar o pacote \"#{@nome}\"."
      @id = nil
    end
    @id = rst.fetch_all.clone
    rst.finish
    Banco.instance.db_disconnect
    @id
  end

end
