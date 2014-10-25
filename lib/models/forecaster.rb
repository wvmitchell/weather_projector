class Forecaster

  attr_reader :location

  def initialize(location)
    @location = Geocoder.coordinates location
  end

  def projection(options)
    date = Time.parse options[:date]
    raw_projection = ForecastIO.forecast(location[0], location[1], time: date.to_i)
    daily = raw_projection.daily.data.first
    [daily.temperatureMax, daily.temperatureMin]
  end

  def heating_degree_days(options)
    temps = projection(options)
    avg = temps.inject(:+) / temps.count.to_f
    hdd = 65 - avg
    hdd > 0 ? hdd : 0
  end

  def cooling_degree_days(options)
    temps = projection(options)
    avg = temps.inject(:+) / temps.count.to_f
    cdd = avg - 65
    cdd > 0 ? cdd : 0
  end

  def absolute_degree_days(options)
    temps = projection(options)
    avg = temps.inject(:+) / temps.count.to_f
    hdd = 65 - avg
    hdd = hdd > 0 ? hdd : 0
    cdd = avg - 65
    cdd = cdd > 0 ? cdd : 0
    (hdd - cdd).round(4)
  end

end
