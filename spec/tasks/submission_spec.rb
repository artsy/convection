# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

describe 'Submission rake tasks' do
  subject(:invoke_task) do
    Rake.application.invoke_task('correction_seq_id')
    Rake.application.invoke_task('rebase_user_submission')
  end

  let!(:user1) { Fabricate(:user, gravity_user_id: 'userid', id: 1) }
  let!(:user1_submission1) { Fabricate(:submission, user: user1) }
  let!(:user1_submission2) { Fabricate(:submission, user: user1) }
  let!(:user1_submission3) { Fabricate(:submission, user: user1) }

  let!(:user2) { Fabricate(:user, gravity_user_id: 'userid2', id: 2) }
  let!(:user2_submission1) { Fabricate(:submission, user: user2) }
  let!(:user2_submission2) { Fabricate(:submission, user: user2) }

  let!(:user3) { Fabricate(:user, gravity_user_id: 'userid3', id: 3) }
  let!(:user3_submission1) { Fabricate(:submission, user: user3) }

  before { invoke_task }

  it 'create a user for each non-unique user_id in the submission' do
    expect(user1_submission1.reload.user.id).to eq(user1.id)
    expect(user1_submission2.reload.user.id).to eq(4) # will create a new user
    expect(user1_submission3.reload.user.id).to eq(5) # will create a new user

    expect(user2_submission1.reload.user.id).to eq(user2.id)
    expect(user2_submission2.reload.user.id).to eq(6) # will create a new user

    expect(user3_submission1.reload.user.id).to eq(user3.id)
    expect(Submission.count).to eq(User.count)
  end
end
