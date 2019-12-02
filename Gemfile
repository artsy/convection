source 'https://rubygems.org'

ruby File.read('.ruby-version')

gem 'rails', '5.2.3'

gem 'pg'
gem 'puma'

gem 'gemini_upload-rails' # for admins to upload images

watt_gem_spec = { git: 'https://github.com/artsy/watt.git', branch: 'master' }
gem 'watt', watt_gem_spec # artsy bootstrap

gem 'artsy-auth'
gem 'artsy-eventservice' # for posting events to artsy event stream
gem 'bootstrap-sass' # required for watt
gem 'bourbon', '4.2.3' # required for watt
gem 'coffee-rails' # required for watt
gem 'decent_exposure' # for safely referencing variables in views
gem 'graphiql-rails', '1.7.0' # A lovely interface to the API
gem 'graphql' # A lovely API
gem 'haml-rails' # required for watt layouts
gem 'hyperclient' # consume Gravity's v2 API
gem 'jquery-rails'
gem 'kaminari' # for pagination
gem 'money' # for currency/money formatting
gem 'neat', '1.7.2' # required for watt
gem 'newrelic_rpm' # for monitoring
gem 'pg_search' # for searching within convection's database
gem 'premailer-rails' # generate text parts from HTML automatically
gem 'rack-cors' # to allow cross-origin requests
gem 'rails_param' # validate and coerce API parameters
gem 'sass-rails'
gem 'sentry-raven' # for error reporting
gem 'sidekiq', '6.0.3' # for sending emails in the background
gem 'uglifier'
gem 'bootsnap', require: false # Speed up boot time by caching expensive operations.

group :development, :test do
  gem 'pry-byebug'
  gem 'rspec-rails'
end

group :development do
  gem 'foreman'
  gem 'rubocop', '0.54.0'
end

group :test do
  gem 'capybara'
  gem 'webdrivers', require: false
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'rack_session_access'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
  gem 'webmock' # mock or forbid external network requests
  gem 'yarjuf' # formatting for test reports on CircleCI
end
