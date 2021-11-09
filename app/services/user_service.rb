# frozen_string_literal: true

class UserService
  class << self
    def anonymize_email!(email)
      User.where(email: email).update_all(email: nil)
    end
  end
end
