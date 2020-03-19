# frozen_string_literal: true

class BaseResolver
  attr_accessor :error

  def initialize(context:, arguments:, object:)
    @context = context
    @arguments = arguments
    @object = object
    @error = nil
  end

  def valid?
    raise 'Implement in subclass'
  end

  def run
    raise 'Implement in subclass'
  end

  private

  def trusted_application?
    @context[:current_application].present?
  end

  def user?
    @context[:current_user_roles].include?(:user)
  end

  def admin?
    @context[:current_user_roles].include?(:admin)
  end
end
