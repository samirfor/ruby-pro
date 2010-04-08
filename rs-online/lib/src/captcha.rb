
# Require GOCR and WGET. In Debian based distros: 
# $apt-get install gocr wget
module Captcha
  # App GOCR is necessary
  def self.recognize(path)
    system("convert #{path} -colorspace Gray #{path}")
    system("convert #{path} -negate #{path}")
    `gocr #{path}`.chomp.delete(" ").strip
  end

  # App WGET is necessary
  def self.save source_url, filename
    system "wget -q \"#{source_url}\" -O #{filename}"
  end
end
