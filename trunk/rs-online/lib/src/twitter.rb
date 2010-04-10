require 'rubygems'
require 'twitter'

#
# Este método depende do RubyGems e da gem "twitter".
# Eles podem ser instalados assim:
#   # apt-get install rubygems gem
#   # gem install twitter
#
module RSTwitter
  def self.tweet evento
    ARGV.each do |e|
      return if e == "no-twitter"
    end
    puts "Twittando: \"#{evento}\""
    autenticacao = Twitter::HTTPAuth.new 'rsonline_', 'rs4all'
    cliente = Twitter::Base.new autenticacao
    if cliente.user_timeline[0].text == evento
      evento += "."
    end
    cliente.update evento
  end
end