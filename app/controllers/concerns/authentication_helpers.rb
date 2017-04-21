module AuthenticationHelpers
  extend ActiveSupport::Concern

  def require_authorized_user
    error!('Unauthorized', 401) unless current_app && current_user
  end

  private

  # For now, require that signature is valid by verifying payload w/ secret.
  # It must have 'aud', with 'sub' optional to be authenticated.
  #
  # If it has both 'aud' and 'sub', then it is user-scoped, with the user_id in 'sub'.
  # All authorization middleware should grant access as appropriate.
  def jwt_payload
    @jwt_payload ||= env['JWT_PAYLOAD']
  end

  def current_app
    @current_app ||= jwt_payload&.fetch('aud', nil)
  end

  def current_user
    @current_user ||= jwt_payload&.fetch('sub', nil)
  end
end
