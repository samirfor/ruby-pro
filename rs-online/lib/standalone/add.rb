#!/usr/bin/env ruby
#
# -- Diretórios de instalação
$:.push "/home/#{`whoami`.chomp}/NetBeansProjects/rs-online/lib/src"
$:.push "/home/#{`whoami`.chomp}/NetBeansProjects/trunk/rs-online/lib/src"
$:.push "/home/#{`whoami`.chomp}/NetBeansProjects/rs-online/lib"
$:.push "/home/#{`whoami`.chomp}/NetBeansProjects/trunk/rs-online/lib"
$:.push "/home/#{`whoami`.chomp}/NetBeansProjects/rs-online/lib/standalone"
$:.push "/home/#{`whoami`.chomp}/NetBeansProjects/trunk/rs-online/lib/standalone"


require 'libglade2'
require "database"
require "pacote"


class RsOnline2Glade
  include GetText

  attr :glade

  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, "UTF-8")
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
    @links = @glade.get_widget("links")
    @nome = @glade.get_widget("nome")
    @senha = @glade.get_widget("senha")
    @prioridade = @glade.get_widget("prioridade")
    @prioridade.active = 0
    @descricao = @glade.get_widget("descricao")
    @local = @glade.get_widget("escolher_local")
    @local.current_folder = "/home/multi/www/videos_scene"
    @submit_erro = @glade.get_widget("submit_erro")
    @submit_ok = @glade.get_widget("submit_ok")
    @url_fonte = @glade.get_widget("url_fonte")
    @legenda = @glade.get_widget("legenda")
    @label_status = @glade.get_widget("label_status")
    @host = get_host_db
    @label_status.set_label "#{@label_status.text}#{@host}"
  end

  def on_window_destroy(widget)
    puts "Good bye\!"
    Gtk.main_quit
  end
  def show_erro msg
    puts "Ocorreu um erro: #{msg}"
    @submit_erro.set_secondary_text(msg)
    @submit_erro.show_all
  end
  def on_submit_clicked(widget)
    begin
      lista = @links.buffer.get_text(nil, nil, false).split("\n")
      links_validos = verify_list(lista)

      # Verifica se há links válidos
      if links_validos.size == 0
        show_erro "Não foi detectado link válido."
        return nil
      end

      pacote = Pacote.new @nome.text
      pacote.prioridade = @prioridade.active + 1
      pacote.senha = @senha.text
      pacote.descricao = @descricao.buffer.text
      pacote.url_fonte = @url_fonte.text
      pacote.legenda = @legenda.text

      links_duplicados = Array.new
      links_db = select_full_links

      # Verifica se links_db é válido
      if links_db == nil
        show_erro "Não foi possível obter todos os links do banco de dados."
        return nil
      end
      # Verifica links duplicados
      links_validos.each do |link|
        links_db.each do |db|
          if link == db
            links_duplicados.push db
          end
        end
      end

      # Captura nome do pacote automaticamente
      if pacote.nome == "" or pacote.nome == nil
        short_link = links_validos[0].split("/")
        path = short_link[short_link.size - 1]
        pacote.nome = path.gsub(/\.part\d+.\S+$/, "").gsub(/\.(rar|zip|\d+)$/, "")
      end

      # Só aceita o pacote se não houver nenhum link duplicado
      unless links_duplicados.size > 0
        pacote.id_pacote = save_pacote(pacote)
        save_links(links_validos, pacote.id_pacote)
        puts "Pacote salvo com sucesso\!"
        @submit_ok.set_secondary_text(links_validos.join("\n"))
        @submit_ok.show_all
      else
        show_erro "Foi detectado um ou mais link duplicado.\n \
                Links duplicados: \n \
                #{links_duplicados.join("\n")}"
      end
      return nil
    rescue Exception => err
      show_erro "Exceção\! \n\n#{err.backtrace.join("\n")}"
      return nil
    end
  end

  def on_clipboard_clicked(widget)
    @links.buffer.paste_clipboard(Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD), nil, true)
  end
  def on_limpar_clicked(widget)
    @links.buffer =  Gtk::TextBuffer.new
    @nome.set_text("")
    @senha.set_text("")
    @prioridade.active = 0
    @url_fonte.set_text("")
    @legenda.set_text("")
    @descricao.buffer = Gtk::TextBuffer.new
    @local.current_folder = GLib.home_dir
  end
  def on_submit_erro_response(widget, arg0)
    widget.set_secondary_text("")
    widget.set_visible false
  end
  def on_submit_ok_response(widget, arg0)
    widget.set_secondary_text("")
    widget.set_visible false
  end
end

def verify_list lista
  links_validos = []
  lista.each do |linha|
    linha.strip!
    if linha =~ /.*(http:\/\/S*rapidshare.com\/\S+\/\S+).*/
      links_validos.push linha.scan(/.*(http:\/\/S*rapidshare.com\/\S+\/\S+).*/)[0][0]
    end
  end
  links_validos
end

# Main program
if __FILE__ == $0
  # Set values as your own application.
  PROG_PATH = "rs-online2.glade"
  PROG_NAME = "RS-Online Standalone Beta"
  RsOnline2Glade.new(PROG_PATH, nil, PROG_NAME)
  Gtk.main
end