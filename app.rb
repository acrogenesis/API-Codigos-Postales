env = ENV['RACK_ENV'] ? ENV['RACK_ENV'] : 'development'
ActiveRecord::Base.logger = Logger.new('debug.log')
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || YAML::load(IO.read('config/database.yml'))[env])

require 'cuba'
require './models/postal_code'

Cuba.define do
  on get do
    on root do
      res.write 'Danos un código postal y te regresamos la colonia, municipio y estado.
                 https://api-codigos-postales.herokuapp.com/codigo_postal/64600'
    end

    on 'codigo_postal/:codigo_postal' do |codigo_postal|
      res.headers['Content-Type'] = 'application/json'
      res.write PostalCode.where(codigo_postal: codigo_postal).to_json
    end
  end
end
