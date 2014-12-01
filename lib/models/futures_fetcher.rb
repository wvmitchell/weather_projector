class FuturesFetcher

  attr_reader :exchange, :code, :month
  attr_accessor :year, :month

  def initialize(options={})
    @exchange = options[:exchange] || 'CME'
    @code = options[:code] || 'HO'
    @month = options[:month] || 'Z'
    @year = options[:year] ? options[:year] : this_or_next_year.to_s
  end

  def get_future_dataset(options={})
    options[:sort_order] ||= 'asc'
    Quandl::Dataset.new("#{exchange}/#{code + month + year}", options).data
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

end
