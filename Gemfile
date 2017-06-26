source 'https://rubygems.org'

ruby '2.4.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem 'artsy-auth'

gem 'rack-cors' # to allow cross-origin requests

gem 'puma', '~> 3.0' # Use Puma as the app server

gem 'sidekiq' # for sending emails in the background
gem 'rails_param', github: 'nicolasblanco/rails_param' # validate and coerce API parameters (use unreleased Rails 5 support)
gem 'hyperclient' # consume Gravity's v2 API
gem 'premailer-rails' # generate text parts from HTML automatically

gem 'newrelic_rpm' # for monitoring

gemini_gem_spec = { git: 'https://github.com/artsy/gemini_upload-rails.git', branch: 'master' }
gem 'gemini_upload-rails', gemini_gem_spec # for admins to upload images

watt_gem_spec = { git: 'https://github.com/artsy/watt.git', branch: 'master' }
gem 'watt', watt_gem_spec # artsy bootstrap
gem 'bootstrap-sass' # required for watt
gem 'bourbon' # required for watt
gem 'neat' # required for watt
gem 'coffee-rails' # required for watt

gem 'kaminari' # for pagination

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'haml-rails' # required for watt layouts

gem 'artsy-eventservice' # for posting events to artsy event stream

group :development, :test do
  gem 'pry-byebug'
  gem 'rspec-rails'
end

group :development do
  gem 'rubocop', require: false
end

group :test do
  gem 'yarjuf' # formatting for test reports on CircleCI
  gem 'webmock' # mock or forbid external network requests
  gem 'capybara', '~> 2.8' # for view tests
  gem 'rails-controller-testing'
end