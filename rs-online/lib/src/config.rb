module RsConfig
  def self.create filepath
    begin
      arq = File.open(filepath, "w")
      arq.puts "Último Pid=#{Process.pid}"
      arq.puts "Local para downloads=#{File.dirname(filepath)}"
      arq.close
      true
    rescue
      false
    end
  end
  def self.parse filepath
    nil unless FileTest.exist? filepath
    begin
      arq = File.open(filepath, "r")
      hash = {
        :pid => arq.readlines[0].split("=")[1].chomp,
        :local => arq.readlines[1].split("=")[1].chomp
      }
      arq.close
      hash
    rescue
      nil
    end
  end
end