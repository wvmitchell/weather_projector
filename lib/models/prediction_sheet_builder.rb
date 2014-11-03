class PredictionSheetBuilder

  attr_reader :location, :abs_degree_days, :filename, :futures_fetcher

  def initialize(options={})
    @location = options[:location] || 'new york ny'
    @abs_degree_days = {}
    @futures_fetcher = FuturesFetcher.new(
                        exchange: options[:exchange],
                        code: options[:code],
                        month: options[:month],
                        year: options[:year]
                      )
    @filename = options[:file] || (Dir.pwd +
                                   '/lib/prediction_sheets/' +
                                   location.gsub(' ', '_') + '_' +
                                   futures_fetcher.code +
                                   futures_fetcher.month +
                                   futures_fetcher.year +
                                   '.csv')
  end

  def forecaster
    @forecaster ||= Forecaster.new(location)
  end

  def build
    futures_set = futures_fetcher.get_future_dataset
    data_points = futures_set['data'].find_all { |day| day[1] > 0.0 }
    CSV.open(filename, 'wb') do |csv|
      data_points.each_with_index do |data_point, index|
        row = []
        date = Date.parse(data_point[0])
        row << ( data_point[5] || 0.0 ) # change in price from previous trading day
        row << date.year
        row << date.month
        row << date.day
        row << date.cwday
        (0..30).to_a.each do |offset|
          offset_date = (date - offset).strftime('%e/%m/%Y')
          degree_days = abs_degree_days[offset_date] || forecaster.absolute_degree_days(date: offset_date)
          abs_degree_days[offset_date] = degree_days
          row << degree_days
        end
        csv << row
      end
    end
  end

  def add_todays_row
    #CSV.open(filename, 'a') do |csv|
    #  row = []
    #  row << date.month
    #  row << date.day
    #  row << date.year
    #  row << date.cwday
    #  (0..30).to_a.each do |offset|
    #    offset_date = (date - offset).strftime('%e/%m/%Y')
    #    degree_days = forecaster.absolute_degree_days(date: offset_date)
    #    row << degree_days
    #  end
    #  csv << row
    #end
  end

end
