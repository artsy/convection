class BaseAbility
  include CanCan::Ability

  def initialize(user)
    alias_action :delete, to: :destroy
  end

  alias_method :original_can?, :can?
  def can?(action, instance_or_klass, *extra_args)
    subject = instance_or_klass.is_a?(Class) ? instance_or_klass.new : instance_or_klass
    original_can?(action.to_sym, subject, *extra_args)
  end
end
