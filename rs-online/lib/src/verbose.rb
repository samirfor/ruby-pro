require "src/historico"

module Verbose
  def self.to_log(text)
    Historico.to_log(text)
  end
  # Gera linhas de log para debug
  def self.to_debug text
    ARGV.each do |arg|
      if arg == "debug"
        puts text
      end
    end
  end
end
