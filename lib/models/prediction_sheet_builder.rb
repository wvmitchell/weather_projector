class PredictionBuilder

  attr_reader :location, :abs_degree_days, :filename, :futures_fetcher

  def initialize(options={})
    @location = options[:location] || 'new york ny'
    @years = options[:years]
    @abs_degree_days = {}
    @futures_fetcher = FuturesFetcher.new(options)
    dir = Dir.pwd + '/lib/prediction_sheets/' + futures_fetcher.code
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    @filename = options[:file] || (Dir.pwd +
                                   '/lib/prediction_sheets/' +
                                   futures_fetcher.code + '/' +
                                   location.gsub(' ', '_') + '_' +
                                   futures_fetcher.code +
                                   '.csv')
  end

  def forecaster
    @forecaster ||= Forecaster.new(location)
  end

  def build
    if @years
      @years.each do |year|
        MONTH_CODES.each_value do |month|
          futures_fetcher.year = year
          futures_fetcher.month = month
          build_or_append_csv
        end
      end
    else
      build_or_append_csv
    end
  end

  def build_or_append_csv
    data_points = futures_fetcher.get_future_dataset
    CSV.open(filename, 'a') do |csv|
      data_points.each_with_index do |data_point, index|
        next if index <= 7
        csv << create_row(data_point, data_points[index-5])
      end
    end
  end

  def build_todays_update
    data_points = futures_fetcher.get_future_dataset(sort_order: 'desc',
                                                                  rows: 5,
                                                                  trim_end: Date.today,
                                                                  trim_start: Date.today-7)
    create_row(data_points.first, data_points.last)
  end

  def build_prediction_for(date)
    row = []
    row << date.year
    row << date.month
    row << date.day
    row << date.cwday
    row << futures_fetcher.year
    row << MONTH_CODES.key(futures_fetcher.month).to_i
    (0..30).to_a.each do |offset|
      offset_date = (date - offset).strftime('%e/%m/%Y')
      degree_days = abs_degree_days[offset_date] || forecaster.absolute_degree_days(date: offset_date)
      abs_degree_days[offset_date] = degree_days
      row << degree_days
    end
    row
  end

  def create_row(data_point1, data_point2)
    row = []
    date = Date.parse(data_point1[0])
    row << percent_price_change( data_point1[6], data_point2[6] ) # % change in price over last week
    row << date.year
    row << date.month
    row << date.day
    row << date.cwday
    row << futures_fetcher.year
    row << MONTH_CODES.key(futures_fetcher.month).to_i
    (0..30).to_a.each do |offset|
      offset_date = (date - offset).strftime('%e/%m/%Y')
      degree_days = abs_degree_days[offset_date] || forecaster.absolute_degree_days(date: offset_date)
      abs_degree_days[offset_date] = degree_days
      row << degree_days
    end
    row
  end

  def percent_price_change(price1, price2)
    ( ( ( price1 - price2 ) / price2 ) * 100 ).round(4)
  end

end
