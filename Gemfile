source 'https://rubygems.org'

ruby '2.4.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'
# Use SCSS for stylesheets
# gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem 'artsy-auth'

gem 'puma', '~> 3.0' # Use Puma as the app server

gem 'sidekiq' # for sending emails in the background
gem 'rails_param', github: 'nicolasblanco/rails_param' # validate and coerce API parameters (use unreleased Rails 5 support)
gem 'hyperclient' # consume Gravity's v2 API
gem 'premailer-rails' # generate text parts from HTML automatically

# Use jquery as the JavaScript library
# gem 'jquery-rails'

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
end
