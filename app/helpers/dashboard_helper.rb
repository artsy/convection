# frozen_string_literal: true

module DashboardHelper
  include ApplicationHelper

  def sum_up_approved_submissions(approved: 0, published: 0, **)
    approved + published
  end
end
