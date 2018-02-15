class UserService
  class << self
    def update_email(user_id)
      user = User.find(user_id)
      email = Gravity.client.user_detail(id: user.gravity_user_id).email
      raise 'User lacks email.' if email.blank?
      user.update_attributes!(email: email) if email != user.email
    end
  end
end
