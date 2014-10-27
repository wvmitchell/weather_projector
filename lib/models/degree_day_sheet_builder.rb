class DegreeDaySheetBuilder

  attr_reader :location, :date, :abs_degree_days, :days_back, :filename

  def initialize(options)
    @location = options[:location]
    @date = options[:date] ? Date.strptime(options[:date], '%m/%e/%Y') : Date.today
    @days_back = options[:days_back] || 30
    @filename = options[:file] || (Dir.pwd + '/lib/degree_days/' + location.gsub(' ', '_') + '.csv')
    @abs_degree_days = {}
  end

  def forecaster
    @forecaster ||= Forecaster.new(location)
  end

  def build
    CSV.open(filename, 'wb') do |csv|
      (0..days_back).to_a.reverse.each do |days|
        row = []
        past_date = date - days
        row << past_date.month
        row << past_date.day
        row << past_date.year
        row << past_date.cwday
        (0..30).to_a.each do |offset|
          offset_date = (past_date - offset).strftime('%e/%m/%Y')
          degree_days = abs_degree_days[offset_date] || forecaster.absolute_degree_days(date: offset_date)
          abs_degree_days[offset_date] = degree_days
          row << degree_days
        end
        csv << row
      end
    end
  end

  def add_todays_row
    CSV.open(filename, 'a') do |csv|
      row = []
      row << date.month
      row << date.day
      row << date.year
      row << date.cwday
      (0..30).to_a.each do |offset|
        offset_date = (date - offset).strftime('%e/%m/%Y')
        degree_days = forecaster.absolute_degree_days(date: offset_date)
        row << degree_days
      end
      csv << row
    end
  end

end
