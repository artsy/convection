Artsy::EventPublisher.configure do |config|
  config.app_id = "artsy-convection" # identifies RabbitMQ connection
  config.enabled = ENV["RABBITMQ_URL"].present? # enable/disable publishing events
  config.rabbitmq_url = ENV["RABBITMQ_URL"] # required
  config.logger = Rails.logger
end
