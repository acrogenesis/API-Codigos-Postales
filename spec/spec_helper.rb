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
require 'warden'

# Load application specific files
require_relative '../db'
require_relative '../app'
require_relative '../models/postal_code'
require_relative '../presenters/postal_codes'
require_relative '../authentication/token_strategy'

# Configure Warden for testing
Warden::Strategies.add(:token, Authentication::TokenStrategy)

# Custom middleware to set JSON content type
class JsonContentType
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    if env['PATH_INFO'] != '/'
      headers['Content-Type'] = 'application/json; charset=utf-8'
    end
    [status, headers, response]
  end
end

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
      use JsonContentType
      use Warden::Manager do |manager|
        manager.default_strategies :token
        manager.failure_app = lambda { |_e|
          [401, { 'Content-Type' => 'application/json' },
           [Oj.dump({ error: 'Not Authorized to use API. Check https://rapidapi.com/acrogenesis/api/mexico-zip-codes' }, mode: :object)]]
        }
      end

      map '/' do
        run Cuba
      end
    end
  end
end