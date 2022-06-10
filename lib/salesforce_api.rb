require 'restforce'

class SalesforceApi
  def self.enabled?
    Convection.config.salesforce_client_id &&
      Convection.config.salesforce_client_secret &&
      Convection.config.salesforce_host &&
      Convection.config.salesforce_username && 
      Convection.config.salesforce_password
  end

  def self.api
    return unless enabled?

    @api ||= Restforce.new \
      username: Convection.config.salesforce_username,
      password: Convection.config.salesforce_password,
      security_token: Convection.config.salesforce_security_token,
      client_id: Convection.config.salesforce_client_id,
      client_secret: Convection.config.salesforce_client_secret,
      host: Convection.config.salesforce_host,
      api_version: '41.0'
  end
end
