require 'time'
require 'rubygems'
require 'bundler'
require 'csv'
require 'google/api_client'
require 'fileutils'
require 'active_support/all'

Bundler.require(:default)

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

LOCATIONS = [
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

FUTURES = {
  'HO' => 'heating_oil'
}

LOCATION_POPULATIONS = {
  'atlanta ga' => 5522942,
  'baltimore md' => 2770738,
  'boston ma' => 4684299,
  'chicago ill' => 9537289,
  'dallas tx' => 6810913,
  'denver co' => 2697476,
  'detroit mi' => 4294983,
  'houston tx' => 6313158,
  'los angeles ca' => 13131431,
  'miami fl' => 5828191,
  'minneapolis mn' => 3459146,
  'new york ny' => 19949502,
  'philadelphia pa' => 6034678,
  'phoenix az' => 4398762,
  'san diego ca' => 3211252,
  'seattle wa' => 3610105,
  'st louis mo' => 2810056,
  'tampa bay fl' => 2870569,
  'washington dc' => 5949859
}

LOCATION_MULTIPLIERS = {}

total_pop = LOCATION_POPULATIONS.values.inject(:+)
LOCATION_POPULATIONS.each do |key, value|
  LOCATION_MULTIPLIERS[key] = (value/total_pop.to_f).round(5)
end

Dir[Dir.pwd + '/config/initializers/*'].each {|init| require init}
