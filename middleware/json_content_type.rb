# Custom middleware to set JSON content type
class JsonContentType
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    headers['Content-Type'] = 'application/json; charset=utf-8' if env['PATH_INFO'] != '/'
    [status, headers, response]
  end
end
