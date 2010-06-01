
# Require GOCR and WGET. In Debian based distros: 
# $apt-get install gocr wget
module Captcha
  # App GOCR is necessary
  def self.recognize(path)
    name_no_ext = "#{path.gsub(/\..+/, "")}"
    new_path = "#{path.gsub(".gif", "")}.tif"
    txt_path = "#{path.gsub(".gif", "")}.txt"
    puts "convert -separate #{path} #{new_path}"
    system "convert -separate #{path} #{new_path}"
    puts "tesseract #{new_path} #{txt_path}"
    system "tesseract #{new_path} #{name_no_ext}"
    captcha = `grep -m 1 . #{txt_path}`.strip
    captcha.delete(" ").gsub(/\W/, "")
#    system("convert #{path} -colorspace Gray #{path}")
#    system("convert #{path} -negate #{path}")
#    `gocr #{path}.tiff`.chomp.delete(" ").strip
  end

  # App WGET is necessary
  def self.save source_url, filename
    system "wget -q \"#{source_url}\" -O #{filename}"
  end
end
