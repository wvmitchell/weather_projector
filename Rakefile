require_relative 'lib/app'
task default: :count_files

desc 'Count the files'
task :count_files do
  puts Dir[Dir.pwd + '/lib/degree_days/*'].count
end

desc 'Count entries per file'
task :add_rows do
   Dir[Dir.pwd + '/lib/degree_days/*'].each do |filename|
     location = filename.split('/')[-1].match(/\w+/).to_s.gsub('_', ' ')
     builder = DegreeDaySheetBuilder.new(location: location, file: filename)
     builder.add_todays_row
   end
end

# When calling this task, do not put spaces in argument list, it won't work
desc 'Build the prediction sheets'
task :build_prediction_sheets, [:code, :month, :year] do |t, args|
  locations = [
    'atlanta ga',
    'baltimore md',
    'boston ma',
    'chicago ill',
    'dallas tx',
    'denver co',
    'detroit mi',
    'houston tx',
    'los angeles ca',
    'miami fl',
    'minneapolis mn',
    'new york ny',
    'philadelphia pa',
    'phoenix az',
    'san diego ca',
    'seattle wa',
    'st louis mo',
    'tampa bay fl',
    'washington dc'
  ]
  locations.each do |location|
    builder = PredictionSheetBuilder.new(location: location,
                                         code: args[:code],
                                         month: args[:month],
                                         year: args[:year])
    builder.build
  end
end

desc 'net degree days'
task :net_degree_days do
   Dir[Dir.pwd + '/lib/degree_days/*'].each do |filename|
     CSV.foreach(filename, 'r') do |row|
       puts "#{row[0]}/#{row[1]}/#{row[2]} #{row[4..-1].map(&:to_f).inject(:+).round(3)}"
     end
   end
end
