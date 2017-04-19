module ErrorHelpers
  extend ActiveSupport::Concern

  def error!(message, status, options = {})
    error_json = { error: message }.merge(options)
    render(json: error_json, status: status)
  end
end
