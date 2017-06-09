module Admin
  class SubmissionsController < Admin::ApplicationController
    def show
      submission = Submission.find(params[:id])
      user = Gravity.client.user(id: submission.user_id)._get
      artist = Gravity.client.artist(id: submission.artist_id)
      render locals: {
        page: Administrate::Page::Show.new(dashboard, requested_resource),
        artist_name: artist.name,
        user_name: user.name,
        user_email: user.user_detail.email
      }
    end

    def index
      resources = Submission.all
      resources = order.apply(resources)
      resources = resources.page(params[:page]).per(records_per_page)

      qualified_filter = 'new'
      if params[:submission] && params[:submission][:qualified]
        qualified_filter = params[:submission][:qualified]
        resources = resources.where(qualified: true) if qualified_filter == 'qualified'
        resources = resources.where(qualified: false) if qualified_filter == 'rejected'
      end

      state_filter = 'submitted'
      if params[:submission] && params[:submission][:state]
        state_filter = params[:submission][:state]
        resources = resources.where(state: state_filter)
      end

      page = Administrate::Page::Collection.new(dashboard, order: order)

      render locals: {
        qualified_filter: qualified_filter,
        state_filter: state_filter,
        resources:       resources,
        page:            page,
        show_search_bar: false
      }
    end
  end
end
