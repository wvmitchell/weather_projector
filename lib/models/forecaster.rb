class Forecaster

  def projection(options)
    location = Geocoder.coordinates options[:location]
    date = Time.parse options[:date]
    raw_projection = ForecastIO.forecast(location[0], location[1], time: date.to_i)
    daily = raw_projection.daily.data.first
    [daily.temperatureMax, daily.temperatureMin]
  end

end
