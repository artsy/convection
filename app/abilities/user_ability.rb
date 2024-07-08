class UserAbility < BaseAbility
  def initialize(user)
    super

    can :download, Asset do |asset|
      user.admin? || asset.user.id == user.id
    end
  end
end