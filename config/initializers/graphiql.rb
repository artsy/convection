GraphiQL::Rails.config.headers['Authorization'] = ->(context) { "Bearer #{context.session[:access_token]}" }
