ENV['RACK_ENV'] = 'test'
ENV['VALIDATE_HEADER'] = 'X-RapidAPI-Key'
ENV['VALIDATE_HEADER_VALUE'] = 'test_token'

require 'rack/test'
require 'rspec'
require 'database_cleaner/active_record'
require 'factory_bot'
require 'faker'

# Load application files
require 'oj'
require 'active_record'
require 'pg'
require 'logger'
require 'dalli'
require 'rack/cache'
require 'cuba'

# Load application specific files
require_relative '../db'
require_relative '../app'
require_relative '../models/postal_code'
require_relative '../presenters/postal_codes'

# Load middleware
require_relative '../middleware/json_content_type'
require_relative '../middleware/header_auth_check'

# Custom middleware classes have been moved to their own files in the middleware directory

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)

    # Load factories
    FactoryBot.find_definitions
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  def app
    Rack::Builder.new do
      # Apply the authentication middleware first
      use HeaderAuthCheck
      # Then apply the JSON content type middleware
      use JsonContentType

      map '/' do
        run Cuba
      end
    end
  end
end
