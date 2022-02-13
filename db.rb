require 'active_record'
require 'yaml'
env = ENV['RACK_ENV'] || 'development'
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || YAML.load(IO.read('config/database.yml'))[env])
