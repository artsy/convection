class UserService
  class << self
    def update_email(user_id)
      user = User.find(user_id)
      email = Gravity.client.user_detail(id: user.gravity_user_id).email
      raise 'User lacks email.' if email.blank?
      user.update!(email: email) if email != user.email
    end

    def anonymize_email!(email)
      users = User.where(email: email)
      users.each { |u| u.update!(email: nil) }
    end
  end
end
