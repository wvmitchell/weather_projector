class FuturesFetcher
  include HTTParty
  base_uri 'http://www.quandl.com/api/v1/datasets'
  default_params 'auth_token' => ENV['QUANDL_API_KEY']

  attr_reader :exchange, :code, :month, :year

  def initialize(options={})
    @exchange = options[:exchange] || 'CME'
    @code = options[:code] || 'HO'
    @month = options[:month] || MONTH_CODES[next_month.to_s]
    @year = options[:year] || this_or_next_year.to_s
  end


  def get_historical_future_range(start_date, end_date)
    klass.get('/GetHistoricalFutureRange', query: {'Symbol' => symbol,
                                                   'Month' => month,
                                                   'Year'  => year,
                                                   'StartDate' => start_date,
                                                   'EndDate' => end_date})
  end

  def get_future_dataset(options={})
    klass.get("/#{exchange}/#{code + month + year}.json")
  end

  def klass
    self.class
  end

  def next_month
    Time.now.month == 12 ? 1 : Time.now.month + 1
  end

  def this_or_next_year
    next_month == 1 ? Time.now.year + 1 : Time.now.year
  end

  MONTH_CODES = {
    '1' => 'F',
    '2' => 'G',
    '3' => 'H',
    '4' => 'J',
    '5' => 'K',
    '6' => 'M',
    '7' => 'N',
    '8' => 'Q',
    '9' => 'U',
    '10' => 'V',
    '11' => 'X',
    '12' => 'Z'
  }

end
