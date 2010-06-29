module StrTime
  # Retorna uma string na forma ideal para o UPDATE no BD.
	def self.timestamp time
    time.strftime("%Y/%m/%d %H:%M:%S")
  end

  def self.now
    self.timestamp(Time.now)
  end

  def self.time time
    time.strftime("%H:%M:%S")
  end
end