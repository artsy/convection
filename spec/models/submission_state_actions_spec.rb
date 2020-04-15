# frozen_string_literal: true

require 'rails_helper'

describe SubmissionStateActions do
  let(:submission) { Fabricate :submission, state: state }

  context 'with a draft submission' do
    let(:state) { 'draft' }

    it 'returns an empty array of actions' do
      actions = SubmissionStateActions.for(submission)
      expect(actions).to eq []
    end
  end

  context 'with a submitted submission' do
    let(:state) { 'submitted' }

    it 'returns approve, publish, reject and close actions' do
      actions = SubmissionStateActions.for(submission)
      states = actions.map { |action| action[:state] }
      expect(states).to eq %w[approved published rejected closed]
    end
  end

  context 'with an approved submission' do
    let(:state) { 'approved' }

    it 'returns the publish action' do
      actions = SubmissionStateActions.for(submission)
      states = actions.map { |action| action[:state] }
      expect(states).to eq %w[published]
    end
  end

  context 'with a published submission' do
    let(:state) { 'published' }

    it 'returns an empty array of actions' do
      actions = SubmissionStateActions.for(submission)
      expect(actions).to eq []
    end
  end

  context 'with a rejected submission' do
    let(:state) { 'rejected' }

    it 'returns an empty array of actions' do
      actions = SubmissionStateActions.for(submission)
      expect(actions).to eq []
    end
  end

  context 'with a closed submission' do
    let(:state) { 'closed' }

    it 'returns an empty array of actions' do
      actions = SubmissionStateActions.for(submission)
      expect(actions).to eq []
    end
  end
end
