require 'quandl'

Quandl.configure do |config|
  config.auth_token = ENV['QUANDL_API_KEY']
end
