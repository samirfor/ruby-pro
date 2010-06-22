module Verbose
  require "src/historico"
  require "src/twitter_bot"
  require "src/celular"
  require "src/sms"

  # Grava na tabela historico
  def self.to_log text
    Historico.to_log text
  end
  # Gera linhas de log para debug
  def self.to_debug text
    ARGV.each do |arg|
      if arg == "debug"
        puts text
      end
    end
  end
  # Envia msg para Twitter
  def self.to_twitter msg
    Thread.new {
      TwitterBot.tweet(msg)
    }
  end
  # Envia msg para celulares através de SMS
  def self.to_sms msg
    Thread.new {
      samir = Celular.new(85, 88016247)
      atila = Celular.new(85, 87999669)
      marcelo = Celular.new(85, 87678424)
      SMS.enviar(msg, samir, atila, marcelo)
    }
  end
  # Envia msg para Twitter e SMS
  def self.to_public msg
    self.to_log(msg)
    self.to_twitter(msg)
    self.to_sms(msg)
  end
end
