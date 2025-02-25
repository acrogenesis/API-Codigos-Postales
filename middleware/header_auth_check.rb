# Authentication middleware
class HeaderAuthCheck
  def initialize(app)
    @app = app
  end

  def call(env)
    # Skip authentication for root path
    return @app.call(env) if env['PATH_INFO'] == '/'

    # Exit early if authentication environment variables are not set
    if !ENV['VALIDATE_HEADER'] || !ENV['VALIDATE_HEADER_VALUE']
      if ENV['RACK_ENV'] != 'production'
        puts 'Authentication configuration error: VALIDATE_HEADER or VALIDATE_HEADER_VALUE not set'
      end
      return [
        500,
        { 'Content-Type' => 'application/json' },
        [Oj.dump({ 'error' => 'Authentication configuration error' }, mode: :object)]
      ]
    end

    # Check if the request has the required authentication header
    header_name = ENV['VALIDATE_HEADER']&.upcase&.gsub('-', '_')
    auth_token = env["HTTP_#{header_name}"] if header_name

    # If no auth token present, immediately reject with 401
    unless auth_token
      puts 'No auth token present, rejecting with 401' if ENV['RACK_ENV'] != 'production'
      return unauthorized_response
    end

    # Validate the token value
    if auth_token != ENV['VALIDATE_HEADER_VALUE']
      puts 'Invalid auth token, rejecting with 401' if ENV['RACK_ENV'] != 'production'
      return unauthorized_response
    end

    # Authentication successful
    puts 'Auth token valid, proceeding' if ENV['RACK_ENV'] != 'production'

    # Continue to the next middleware
    @app.call(env)
  end

  private

  def unauthorized_response
    [
      401,
      { 'Content-Type' => 'application/json' },
      [Oj.dump(
        { 'error' => 'Not Authorized to use API. Check https://rapidapi.com/acrogenesis-llc-api/api/mexico-zip-codes' }, mode: :object
      )]
    ]
  end
end
