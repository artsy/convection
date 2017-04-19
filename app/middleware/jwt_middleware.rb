class JwtMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['HTTP_AUTHORIZATION']
      token = parse_header env['HTTP_AUTHORIZATION']

      begin
        env['JWT_PAYLOAD'], _headers = JWT.decode(token, Convection.config.jwt_secret)
      rescue
        Rails.logger.info "Unable to parse JWT: #{token}"
      end
    end
    @app.call env
  end

  def parse_header(header)
    header.split(' ').last
  end
end
