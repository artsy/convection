# frozen_string_literal: true

require "rails_helper"

describe SubmissionStateActions do
  let(:submission) { Fabricate :submission, state: state }

  context "with a draft submission" do
    let(:state) { "draft" }

    it "returns approve, publish, hold, reject and close actions" do
      actions = SubmissionStateActions.for(submission)
      states = actions.pluck(:state)
      expect(states).to eq %w[approved published hold rejected closed]
    end
  end

  context "with a submitted submission" do
    let(:state) { "submitted" }

    it "returns approve, publish, hold, reject and close actions" do
      actions = SubmissionStateActions.for(submission)
      states = actions.pluck(:state)
      expect(states).to eq %w[approved published hold rejected closed]
    end
  end

  context "with a resubmitted submission" do
    let(:state) { "resubmitted" }

    it "returns published, hold and close actions" do
      actions = SubmissionStateActions.for(submission)
      states = actions.pluck(:state)
      expect(states).to eq %w[published hold closed]
    end
  end

  context "with an approved submission" do
    let(:state) { "approved" }

    it "returns the publish, hold and close actions" do
      actions = SubmissionStateActions.for(submission)
      states = actions.pluck(:state)
      expect(states).to eq %w[published hold closed]
    end
  end

  context "with a published submission" do
    let(:state) { "published" }

    it "returns the close action" do
      actions = SubmissionStateActions.for(submission)
      states = actions.pluck(:state)
      expect(states).to eq %w[closed]
    end
  end

  context "with an on hold submission" do
    let(:state) { "hold" }

    it "returns approve, publish, reject and close actions" do
      actions = SubmissionStateActions.for(submission)
      states = actions.pluck(:state)
      expect(states).to eq %w[approved published rejected closed]
    end
  end

  context "with a rejected submission" do
    let(:state) { "rejected" }

    it "returns an empty array of actions" do
      actions = SubmissionStateActions.for(submission)
      expect(actions).to eq []
    end
  end

  context "with a closed submission" do
    let(:state) { "closed" }

    it "returns an empty array of actions" do
      actions = SubmissionStateActions.for(submission)
      expect(actions).to eq []
    end
  end
end
