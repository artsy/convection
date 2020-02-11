class Gravity
  class << self
    def client
      @client ||=
        Hyperclient.new(Convection.config.gravity_api_url) do |client|
          client.headers['X-XAPP-TOKEN'] = Convection.config.gravity_xapp_token
          client.headers['ACCEPT'] = 'application/vnd.artsy-v2+format'
        end
    end

    def fetch_all(object, link_sym, params = {})
      items = []
      cursor = object.send(link_sym, params)._get
      loop do
        new_items = cursor.try(link_sym)
        items += new_items if new_items
        cursor = cursor.try(:next)
        break if new_items.blank?
      end
      items
    end
  end
end
