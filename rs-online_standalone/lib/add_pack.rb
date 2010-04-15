#!/usr/bin/env ruby
#
# This file is gererated by ruby-glade-create-template 1.1.4.
#
require 'libglade2'
#require "database"

class RsOnline2Glade
  include GetText

  attr :glade

  def initialize(path_or_data, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, "UTF-8")
    @glade = GladeXML.new(path_or_data, root, domain, localedir, flag) {|handler| method(handler)}
    @links = @glade.get_widget("links")
    @nome = @glade.get_widget("nome")
    @senha = @glade.get_widget("senha")
    @descricao = @glade.get_widget("descricao")
    @local = @glade.get_widget("escolher_local")
    @local.current_folder = "/home/multi/www/videos_scene"
    @submit_erro = @glade.get_widget("submit_erro")
    @submit_ok = @glade.get_widget("submit_ok")
  end

  def on_escolher_local_current_folder_changed(widget)
    #@local.current_folder = widget.current_folder
    #puts "on_escolher_local_current_folder_changed() is not implemented yet."
  end
  def on_window_destroy(widget)
    puts "Good bye\!"
    Gtk.main_quit
  end
  def on_submit_clicked(widget)
    lista = @links.buffer.get_text(nil, nil, false).split("\n")
    links_validos = verify_list(lista)
    # Verifica se há links válidos
    if links_validos.size == 0
      @submit_erro.set_secondary_text("Não foi detectado link válido.")
      @submit_erro.show_all
      return nil
    end
    puts "save_pacote\!"
    @submit_ok.set_secondary_text(lista.join("\n"))
    @submit_ok.show_all
    #    save_pacote(pacote)
  end
  def on_clipboard_clicked(widget)
    @links.buffer.paste_clipboard(Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD), nil, true)
  end
  def on_cancelar_clicked(widget)
    @links.buffer =  Gtk::TextBuffer.new
    @nome.set_text("")
    @senha.set_text("")
    @descricao.buffer = Gtk::TextBuffer.new
    @local.current_folder = GLib.home_dir
  end
  def on_submit_erro_response(widget, arg0)
    widget.set_secondary_text("")
    widget.set_visible false
  end
  def submit_ok_response_cb(widget, arg0)
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