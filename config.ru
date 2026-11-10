require 'oj'
require 'active_record'
require 'pg'
require 'logger'
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

use JsonContentType
run Cuba
