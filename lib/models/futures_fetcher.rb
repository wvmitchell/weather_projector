class FuturesFetcher
  include HTTParty
  base_uri 'http://www.xignite.com/xFutures.json'

  attr_reader :symbol, :month, :year

  def initialize(options)
    @symbol = options[:symbol]
    @month = options[:month]
    @year = options[:year]
  end

  def get_historical_future(as_of_date)
    res = klass.get('/GetHistoricalFuture', query: {'Symbol' => symbol,
                                                    'Month' => month,
                                                    'Year'  => year,
                                                    'AsOfDate' => as_of_date})
    binding.pry
    res
  end

  def klass
    self.class
  end

end
