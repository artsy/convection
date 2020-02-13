# frozen_string_literal: true

source 'https://rubygems.org'

ruby File.read('.ruby-version')

gem 'rails', '6.0.2.1'

gem 'pg'
gem 'puma'

watt_gem_spec = { git: 'https://github.com/artsy/watt.git', branch: 'master' }
gem 'watt', watt_gem_spec # artsy bootstrap

gem 'artsy-auth'
gem 'artsy-eventservice' # for posting events to artsy event stream
gem 'bootsnap', require: false # Speed up boot time by caching expensive operations.
gem 'bootstrap-sass' # required for watt
gem 'bourbon', '4.2.3' # required for watt
gem 'coffee-rails' # required for watt
gem 'ddtrace', '~> 0.32.0'
gem 'decent_exposure' # for safely referencing variables in views
gem 'gemini_upload-rails' # for admins to upload images
gem 'graphiql-rails', '1.7.0' # A lovely interface to the API
gem 'graphql' # A lovely API
gem 'haml-rails' # required for watt layouts
gem 'hyperclient' # consume Gravity's v2 API
gem 'jquery-rails'
gem 'kaminari' # for pagination
gem 'money' # for currency/money formatting
gem 'neat', '1.7.2' # required for watt
gem 'pg_search' # for searching within convection's database
gem 'premailer-rails' # generate text parts from HTML automatically
gem 'rack-cors' # to allow cross-origin requests
gem 'rails_param' # validate and coerce API parameters
gem 'redcarpet'
gem 'sass-rails'
gem 'sentry-raven' # for error reporting
gem 'sidekiq', '<6' # for sending emails in the background (<6 necessary for Redis 3 compatibility)
gem 'uglifier'

group :development, :test do
  gem 'pry-byebug'
  gem 'rspec-rails', '4.0.0.beta4'
  gem 'rubocop-rails'
  gem 'webdrivers', '~> 4.2'
end

group :development do
  gem 'foreman'
  gem 'guard-livereload', require: false
  gem 'rack-livereload'
  gem 'solargraph' # VSCode language server for autocompletion
end

group :test do
  gem 'capybara', '~> 3.31.0'
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'rack_session_access'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
  gem 'webmock' # mock or forbid external network requests
  gem 'yarjuf' # formatting for test reports on CircleCI
end
