require 'oj'
require 'active_record'
require 'pg'
require 'logger'
require 'dalli'
require 'rack/cache'
require 'cuba'
require 'warden'

# Load .env file in development environment
if ENV['RACK_ENV'] != 'production'
  require 'dotenv'
  Dotenv.load
end

require './db'
require './app'
require './models/postal_code'
require './presenters/postal_codes'
require './authentication/token_strategy'

# Configure Cuba to handle JSON responses
Cuba.settings[:format] = :json
Cuba.settings[:content_type] = 'application/json; charset=utf-8'

# Define a middleware to set JSON content type for all responses except root
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

if ENV['VALIDATE_HEADER']
  Warden::Strategies.add(:token, Authentication::TokenStrategy)
  use Warden::Manager do |manager|
    manager.default_strategies :token
    manager.failure_app = lambda { |_e|
      [401, { 'Content-Type' => 'application/json' },
       [Oj.dump({ error: 'Not Authorized to use API. Check https://rapidapi.com/acrogenesis/api/mexico-zip-codes' }, mode: :object)]]
    }
  end
end

if ENV['MEMCACHEDCLOUD_USERNAME']
  client = Dalli::Client.new((ENV['MEMCACHEDCLOUD_SERVERS'] || 'memcached://localhost:11211').split(','),
                             username: ENV['MEMCACHEDCLOUD_USERNAME'],
                             password: ENV['MEMCACHEDCLOUD_PASSWORD'],
                             failover: true,
                             socket_timeout: 1.5,
                             socket_failure_delay: 0.2,
                             value_max_bytes: 10_485_760)

  use Rack::Cache,
      verbose: true,
      metastore: client,
      entitystore: client
end

use JsonContentType
run Cuba
