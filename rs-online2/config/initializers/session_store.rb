# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rs-online2_session',
  :secret      => '0b8cded51c38f06ecf19bbefb84b6690ee7098b00066531e70a9e58214d59a70cc6893b1fe16df24172dff981fec53c9c3b260b37897214773b5d10674bfb455'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
