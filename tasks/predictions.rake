namespace :predictions do

  # When calling this task, do not put spaces in argument list, it won't work
  desc 'Build the prediction sheets'
  task :build_sheets, [:code, :start_year, :end_year] do |t, args|
    LOCATIONS.each do |location|
      years = (args[:start_year]..args2[:end_year]).to_a
      builder = PredictionBuilder.new(location: location,
                                      code: args[:code],
                                      years: years)
      builder.build
    end
  end

  desc 'Train the prediction models'
  task :train_models, [:code, :month, :year] do |t, args|
    LOCATIONS.each do |location|
      predictor = Predictor.new(location: location,
                                code: args[:code],
                                month: args[:month],
                                year: args[:year])
      predictor.train
    end
  end

  desc 'Update the prediction models'
  task :update_models, [:code, :month, :year] do |t, args|
    LOCATIONS.each do |location|
      predictor = Predictor.new(location: location,
                                code: args[:code],
                                month: args[:month],
                                year: args[:year])
      predictor.update
    end
  end

  desc 'Get predictions from areas based on date (YYYY-MM-DD)'
  task :get_predictions, [:code, :month, :year, :date] do |t, args|
    date = Date.parse(args[:date])
    predictions = {}
    LOCATIONS.each do |location|
      predictor = Predictor.new(location: location,
                                code: args[:code],
                                month: args[:month],
                                year: args[:year])
      res = predictor.predict(date: date)
      predictions[location] = JSON.parse(res.body)['outputValue'].to_f
      puts "#{location} : #{JSON.parse(res.body)['outputValue']}"
    end
    puts predictions
    composite = predictions.inject(0) {|c, (k, v)| c + LOCATION_MULTIPLIERS[k] * v }.round(4)
    puts "Composite prediction: #{composite}"
  end

  desc 'Get a prediction from a single area based on date (YYYY-MM-DD)'
  task :get_prediction, [:code, :month, :year, :date, :location] do |t, args|
    date = Date.parse(args[:date])
    predictor = Predictor.new(location: args[:location],
                              code: args[:code],
                              month: args[:month],
                              year: args[:year])
    res = predictor.predict(date: date)
    puts "#{args[:location]} : #{JSON.parse(res.body)['outputValue']}"
  end

end
