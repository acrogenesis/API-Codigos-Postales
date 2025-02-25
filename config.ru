require 'oj'
require 'active_record'
require 'pg'
require 'logger'
require 'dalli'
require 'rack/cache'
require 'cuba'

# Load .env file in development environment
if ENV['RACK_ENV'] != 'production'
  require 'dotenv'
  Dotenv.load
end

require './db'
require './app'
require './models/postal_code'
require './presenters/postal_codes'

# Load middleware
require './middleware/json_content_type'
require './middleware/header_auth_check'

# Configure Cuba to handle JSON responses
Cuba.settings[:format] = :json
Cuba.settings[:content_type] = 'application/json; charset=utf-8'

# Apply the header auth check middleware
use HeaderAuthCheck

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
