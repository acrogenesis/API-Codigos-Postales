env = ENV['RACK_ENV'] ? ENV['RACK_ENV'] : 'development'
ActiveRecord::Base.logger = Logger.new('debug.log')
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || YAML::load(IO.read('config/database.yml'))[env])
