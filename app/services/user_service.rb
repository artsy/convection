# frozen_string_literal: true

class UserService
  class << self
    def update_email(user_id)
      return if user_id == User.anonymous.id

      user = User.find(user_id)
      email = user.user_email
      raise 'User lacks email.' if email.blank?

      user.update!(email: email) if email != user.email
    end

    def anonymize_email!(email)
      User.where(email: email).update_all(email: nil)
    end
  end
end
