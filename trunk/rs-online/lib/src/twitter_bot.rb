require "rubygems"

module TwitterBot
  activate = false
  activate = true if require "twitter"

  if activate
    def self.tweet msg
      Twitter::Client.configure do |conf|
        # We can set Twitter4R to use <tt>:ssl</tt> or <tt>:http</tt> to connect to the Twitter API.
        # Defaults to <tt>:ssl</tt>
        # conf.protocol = :ssl

        # We can set Twitter4R to use another host name (perhaps for internal
        # testing purposes).
        # Defaults to 'twitter.com'
        # conf.host = 'twitter.com'

        # We can set Twitter4R to use another port (also for internal
        # testing purposes).
        # Defaults to 443
        # conf.port = 443

        # We can set proxy information for Twitter4R
        # By default all following values are set to <tt>nil</tt>.
        # conf.proxy_host = 'myproxy.host'
        # conf.proxy_port = 8080
        # conf.proxy_user = 'myuser'
        # conf.proxy_pass = 'mypass'

        # We can also change the User-Agent and X-Twitter-Client* HTTP headers
        conf.user_agent = 'rsonline'
        conf.application_name = 'RS-Online'
        conf.application_version = 'v2.0b'
        conf.application_url = 'http://code.google.com/p/ruby-pro/source/browse/trunk/rs-online'

        # Twitter (not Twitter4R) will have to setup a source ID for your application to get it
        # recognized by the web interface according to your preferences.
        # To see more information how to go about doing this, please referen to the following thread:
        # http://groups.google.com/group/twitter4r-users/browse_thread/thread/c655457fdb127032
        #conf.source = "your-source-id-that-twitter-recognizes"
        conf.source = "xiPQ7mRYsiKUefOXGKqzRA"
      end
      client = Twitter::Client.new :login => "rsonline_", :password => "rs4all"
      client.status(:post, msg)
    end
  else
    def self.tweet msg
      Verbose.to_debug("Twitter não ativo.\nSuposta msg: #{msg}")
    end
  end
end
