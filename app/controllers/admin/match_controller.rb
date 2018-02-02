module Admin
  class MatchController < ApplicationController
    def match
      results = []
      if params[:match_users]
        users_result = { label: 'users', results: User.search(params[:term]).take(5) }
        results << users_result
      end
      results << { label: 'test', results: [{ name: 'sarah' }, { name: 'joe' }] }
      respond_to do |format|
        format.json { render json: results }
      end
    end
  end
end
