# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
if Rails.env.production?
  abort("The Rails environment is running in production mode!")
end
require "spec_helper"
require "rspec/rails"
require "sidekiq/testing"
require "webmock/rspec"
require "rack_session_access/capybara"

WebMock.disable_net_connect!(
  allow_localhost: true
)

ActiveRecord::Migration.maintain_test_schema!

Sidekiq::Testing.inline!

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  config.before(:suite) { DatabaseCleaner.strategy = :truncation }

  config.around { |example| DatabaseCleaner.cleaning { example.run } }

  config.before(:each) do
    Sidekiq::Worker.clear_all
    ActionMailer::Base.deliveries.clear
  end

  config.before(:each, type: :system) { driven_by :headless_chrome }

  if Bullet.enable?
    config.before do |example|
      bullet_start_request_block = proc do
        Bullet.start_request
      end

      hooks = example.send(:hooks)
      hooks.register(:append, :before, :each, &bullet_start_request_block)
    end

    config.after do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end
end

Capybara.configure do |config|
  config.javascript_driver = :headless_chrome
  config.default_max_wait_time = 10
  config.ignore_hidden_elements = false
end

Capybara.register_driver :headless_chrome do |app|
  opts = Selenium::WebDriver::Chrome::Options.new

  opts.add_argument("--headless")
  opts.add_argument("--no-sandbox")
  opts.add_argument("--disable-dev-shm-usage")
  opts.add_argument("--window-size=1440,900")
  opts.add_preference(:loggingPrefs, {browser: "ALL"})

  args = {
    browser: :chrome,
    options: opts
  }

  Capybara::Selenium::Driver.new(app, **args)
end
