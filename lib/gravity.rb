class Gravity
  def self.client
    @client ||= Hyperclient.new(Convection.config.gravity_api_url) do |client|
      client.headers['X-XAPP-TOKEN'] = Convection.config.gravity_xapp_token
      client.headers['ACCEPT'] = 'application/vnd.artsy-v2+format'
    end
  end
end
