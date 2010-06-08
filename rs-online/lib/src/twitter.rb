## Deprecated



require "src/historico"

twitter = true
begin
  require 'rubygems'
  require 'twitter' # gem install twitter
rescue Exception => e
  twitter = false
  Historico.to_log "Não foi possível carregar o twitter: #{e.message}"
end

#
# Este método depende do RubyGems e da gem "twitter".
# Eles podem ser instalados assim:
#   # apt-get install rubygems gem
#   # gem install twitter
#
if twitter
  module RSTwitter
    def self.tweet evento
      ARGV.each do |e|
        return if e == "no-twitter"
      end
      puts "Twittando: \"#{evento}\""
      autenticacao = Twitter::HTTPAuth.new 'rsonline_', 'rs4all'
      cliente = Twitter::Base.new autenticacao
      begin
        if cliente.user_timeline[0].text == evento
          evento += "."
        end
      rescue
      end
      cliente.update evento
    end
  end
else
  module RSTwitter
    def self.tweet evento
    end
  end
end