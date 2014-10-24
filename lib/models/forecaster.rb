require 'forecast_io'
require 'dotenv'
Dotenv.load

ForecastIO.configure do |config|
  config.api_key = ENV['FORECASTIO_API_KEY']
end

class Forecaster
end
