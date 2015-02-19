require 'active_record'
require 'yaml'
require './db'
desc 'Run migrations'
namespace :db do
  task :migrate do
    ActiveRecord::Migrator.migrate('db/migrate', ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
  end
end
