class BrazeApi
  class TryAgainError < StandardError
  end

  def self.generate_client
    api_key = Convection.config.braze_api_key
    api_url = Convection.config.braze_api_url

    return unless api_key && api_url

    BrazeRuby::API.new(api_key, api_url)
  end

  def self.client
    @client ||= generate_client
  end

  def self.trigger_campaign_send(campaign_id, recipients)
    return nil unless client

    response =
      client.trigger_campaign_send(
        campaign_id: campaign_id,
        recipients: recipients
      )

    handle_response(response)
  end

  def self.handle_response(response)
    raise TryAgainError if (500...600).include?(response.status)

    body =
      begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        { 'errors' => 'unable to parse response as json' }.freeze
      end

    if body['errors']
      error_message = "Braze API Errors: #{body['errors']}"
      Raven.capture_message(error_message)
    end

    body
  end
end
