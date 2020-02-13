# frozen_string_literal: true

class UserService
  class << self
    def update_email(user_id)
      user = User.find(user_id)
      email = Gravity.client.user_detail(id: user.gravity_user_id).email
      raise 'User lacks email.' if email.blank?

      user.update!(email: email) if email != user.email
    end

    def anonymize_email!(email)
      User.where(email: email).update_all(email: nil)
    end
  end
end
