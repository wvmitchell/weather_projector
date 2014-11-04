require 'time'
require 'rubygems'
require 'bundler'
require 'csv'
require 'google/api_client'
Bundler.require(:default)

Dir[Dir.pwd + '/config/initializers/*'].each {|init| require init}
