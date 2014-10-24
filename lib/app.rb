require 'rubygems'
require 'bundler'
Bundler.require(:default)

Dir[Dir.pwd + '/config/initializers/*'].each {|init| require init}
