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
    @context[:current_application].present? && @context[:current_user_roles].include?(:trusted)
  end

  def user?
    @context[:current_user_roles].include?(:user)
  end

  def partner?
    @context[:current_user_roles].include?(:partner)
  end

  def admin?
    @context[:current_user_roles].include?(:admin)
  end

  def matching_user(submission, session_id)
    submitted_by_current_user?(submission) ||
      submitted_by_current_session?(submission, session_id)
  end

  def submitted_by_current_user?(submission)
    submission.user&.gravity_user_id.present? &&
      submission.user&.gravity_user_id == @context&.[](:current_user)
  end

  def submitted_by_current_session?(submission, session_id)
    session_id.present? && submission.session_id == session_id
  end
end
