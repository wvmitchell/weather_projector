require 'time'
require 'rubygems'
require 'bundler'
require 'csv'
Bundler.require(:default)

Dir[Dir.pwd + '/config/initializers/*'].each {|init| require init}

CSV.open(Dir.pwd + '/lib/denver_output.csv', 'wb') do |csv|
  f = FuturesFetcher.new(symbol: 'HO', month: '1', year: '2015')
  res = f.get_historical_future_range('06/30/2014', '07/30/2014')
  abs_degree_days = {}
  forcaster = Forecaster.new('denver co')
  res['Quotes'].each_with_index do |quote, index|
    next if index == 0
    date = Date.strptime(quote['Date'], '%m/%e/%Y')
    row = []
    row << quote['Settle']
    row << res['Quotes'][index-1]['Settle']
    (0..30).to_a.each do |offset|
      offset_date = (date - offset).strftime('%e/%m/%Y')
      add = abs_degree_days[offset_date] || forcaster.absolute_degree_days(date: offset_date)
      abs_degree_days[offset_date] = add
      row << add
    end
    csv << row
  end
end
