require_relative 'lib/app'
task default: :task_list
Dir[Dir.pwd + '/tasks/*'].each {|task| load task }

desc 'List all available rake tasks'
task :task_list do
  puts `rake -T`
end

desc 'net degree days'
task :net_degree_days do
   Dir[Dir.pwd + '/lib/degree_days/*'].each do |filename|
     CSV.foreach(filename, 'r') do |row|
       puts "#{row[0]}/#{row[1]}/#{row[2]} #{row[4..-1].map(&:to_f).inject(:+).round(3)}"
     end
   end
end
