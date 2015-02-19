require 'active_record'
require 'yaml'
desc 'Run migrations'
namespace :db do
  task :migrate do
    env = ENV['RACK_ENV'] ? ENV['RACK_ENV'] : 'development'
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || YAML::load(IO.read('config/database.yml'))[env])
    ActiveRecord::Migrator.migrate('db/migrate', ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
  end
end
