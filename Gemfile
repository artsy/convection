source 'https://rubygems.org'

ruby '2.4.3'

gem 'pg', '0.21.0'
gem 'puma'
gem 'rails', '5.0.6'

gemini_gem_spec = { git: 'https://github.com/artsy/gemini_upload-rails.git', branch: 'master' }
gem 'gemini_upload-rails', gemini_gem_spec # for admins to upload images

watt_gem_spec = { git: 'https://github.com/artsy/watt.git', branch: 'master' }
gem 'watt', watt_gem_spec # artsy bootstrap

gem 'artsy-auth'
gem 'artsy-eventservice' # for posting events to artsy event stream
gem 'bootstrap-sass' # required for watt
gem 'bourbon', '4.2.3' # required for watt
gem 'coffee-rails' # required for watt
gem 'decent_exposure' # for safely referencing variables in views
gem 'graphiql-rails' # A lovely interface to the API
gem 'graphql' # A lovely API
gem 'haml-rails' # required for watt layouts
gem 'hyperclient' # consume Gravity's v2 API
gem 'jquery-rails'
gem 'kaminari' # for pagination
gem 'neat', '1.7.2' # required for watt
gem 'newrelic_rpm' # for monitoring
gem 'pg_search' # for searching within convection's database
gem 'premailer-rails' # generate text parts from HTML automatically
gem 'rack-cors' # to allow cross-origin requests
gem 'rails_param' # validate and coerce API parameters
gem 'sass-rails'
gem 'sentry-raven' # for error reporting
gem 'sidekiq', '4.2.9' # for sending emails in the background
gem 'uglifier'

group :development, :test do
  gem 'pry-byebug'
  gem 'rspec-rails'
end

group :development do
  gem 'foreman'
  gem 'rubocop', '0.47.1', require: false
end

group :test do
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'rack_session_access'
  gem 'rails-controller-testing'
  gem 'webmock' # mock or forbid external network requests
  gem 'yarjuf' # formatting for test reports on CircleCI
end
