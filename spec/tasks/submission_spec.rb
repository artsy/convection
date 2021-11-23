# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

describe 'Submission rake tasks' do
  describe 'Submission lapse sent rake task' do
    subject(:invoke_task) do
      Rake.application.invoke_task('rebase_user_submission')
    end

    let!(:user1) { Fabricate(:user, gravity_user_id: 'userid', id: 1) }
    let!(:user1_submission1) { Fabricate(:submission, user: user1) }
    let!(:user1_submission2) { Fabricate(:submission, user: user1) }
    let!(:user1_submission3) { Fabricate(:submission, user: user1) }

    let!(:user2) { Fabricate(:user, gravity_user_id: 'userid2', id: 2) }
    let!(:submission4) { Fabricate(:submission, user: user2) }
    let!(:submission5) { Fabricate(:submission, user: user2) }

    it "update the state if offer is set to 'sent' before a certain date" do
      expect { invoke_task }.not_to(change { user1_submission1.reload.user.id })
      expect { invoke_task }.to(
        change { user1_submission2.reload.user.id }.from(1).to(3)
      )
      expect { invoke_task }.to(
        change { user1_submission3.reload.user.id }.from(1).to(4)
      )

      expect { invoke_task }.to(
        change { user1_submission2.reload.user.id }.from(1).to(5)
      )
      expect { invoke_task }.to(
        change { user1_submission3.reload.user.id }.from(1).to(6)
      )
    end
  end
end
