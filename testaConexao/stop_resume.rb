#!/usr/bin/env ruby

require 'net/http'
require 'logger'

def to_log(texto)
     logger = Logger.new('stop-resume.log', 10, 1024000)
     logger.datetime_format = "%d/%m %H:%M:%S"
     logger.info(texto)
     logger.close
     puts texto
end

def stop
     url = URI.parse('http://localhost/action/stop')
     http = Net::HTTP.new(url.host, 10025)
     headers, body = http.get(url.path)
     if headers.code == "200"
          to_log("Parando JDownloader.")
          sleep(5)
     else
          to_log("Falha no stop: #{headers.code} #{headers.message}")
          `zenity --error --text='#{headers.code} #{headers.message}'`
     end
end

def resume     
     url = URI.parse('http://localhost/action/start')
     http = Net::HTTP.new(url.host, 10025)
     headers, body = http.get(url.path)
     if headers.code == "200"
          to_log("Resumindo JDownloader.")
          sleep(1)
     else
          to_log("Falha no resume: #{headers.code} #{headers.message}")
          `zenity --error --text='#{headers.code} #{headers.message}'`
     end
end
