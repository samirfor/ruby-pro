
# Require GOCR and WGET. In Debian based distros: 
# $apt-get install gocr wget tesseract-ocr

module Captcha

  # App WGET is necessary
  def self.save source_url, filename
    system "wget -q \"#{source_url}\" -O #{filename}"
  end

  # http://www.megaupload.com/
  module Megaupload
    # App GOCR is necessary
    def self.recognize(path)
      name_no_ext = "#{path.gsub(/\..+/, "")}"
      new_path = "#{path.gsub(".gif", "")}.tif"
      txt_path = "#{path.gsub(".gif", "")}.txt"
      system "convert -separate #{path} #{new_path}"
      system "tesseract #{new_path} #{name_no_ext}"
      captcha = `grep -m 1 . #{txt_path}`.strip
      captcha = captcha.delete(" ").gsub(/\W/, "")
      begin
        File.delete(new_path)
        File.delete(txt_path)
        File.delete(path)
      rescue
        puts "warning: erro na remoção de arquivo(s) temporário(s)."
      end
      captcha
    end
  end

  # http://www.torpedogratis.net/
  module TorpedoGratis
#    # App GOCR is necessary
#    def self.recognize(path)
#      system("convert #{path} -colorspace Gray #{path}")
#      system("convert #{path} -negate #{path}")
#      captcha = `gocr #{path}`.chomp.delete(" ").strip
#      nil unless captcha.size == 4
#      begin
#        File.delete(path)
#      rescue
#        puts "warning: erro na remoção de arquivo(s) temporário(s)."
#      end
#      captcha
#    end

     # App GOCR is necessary
    def self.recognize(path)
      name_no_ext = "#{path.gsub(/\..+/, "")}"
      new_path = "#{path.gsub(".png", "")}.tif"
      txt_path = "#{path.gsub(".png", "")}.txt"
      system "convert -monochrome #{path} #{path}"
      system "convert -separate #{path} #{new_path}"
      system "tesseract #{new_path} #{name_no_ext}"
      captcha = `grep -m 1 . #{txt_path}`.strip
      captcha = captcha.delete(" ").gsub(/\W/, "")
      begin
        #File.delete(new_path)
        #File.delete(txt_path)
        #File.delete(path)
      rescue
        puts "warning: erro na remoção de arquivo(s) temporário(s)."
      end
      captcha
    end

  end
end
