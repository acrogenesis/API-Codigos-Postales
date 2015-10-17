require 'oj'
require 'active_record'
require 'pg'
require 'logger'
require 'dalli'
require 'rack/cache'
require 'cuba'
require './db'
require './app'
require './models/postal_code'
require './presenters/postal_codes'

if ENV['RACK_ENV'] == 'production'
  require 'rack/ssl'
  use Rack::SSL
end

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

run Cuba
