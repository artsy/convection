# frozen_string_literal: true

require 'rails_helper'

describe SubmissionMatch do
  describe '.find_all' do
    context 'with an otherwise matching deleted submission' do
      let!(:submission) { Fabricate :submission, deleted_at: Time.zone.now }

      it 'excludes that submission' do
        params = {}
        matching = SubmissionMatch.find_all(params).to_a
        expect(matching).to eq []
      end
    end

    context 'filtering by state' do
      let(:state) { 'submitted' }
      let!(:submitted_submission) { Fabricate :submission, state: state }
      let!(:draft_submission) { Fabricate :submission, state: 'draft' }

      it 'returns only matching submissions' do
        params = { state: state }
        matching = SubmissionMatch.find_all(params).to_a
        expect(matching).to eq [submitted_submission]
      end
    end

    context 'filtering by user' do
      let(:user) { Fabricate :user }
      let(:another_user) { Fabricate :user }
      let!(:submission) { Fabricate :submission, user: user }
      let!(:another_submission) { Fabricate :submission, user: another_user }

      it 'returns only matching submissions' do
        params = { user: user.id }
        matching = SubmissionMatch.find_all(params).to_a
        expect(matching).to eq [submission]
      end
    end

    context 'searching with term' do
      let(:query) { 'mushroom' }
      let!(:submission) do
        Fabricate :submission, title: "Contains the #{query} term!!"
      end
      let!(:another_submission) do
        Fabricate :submission, title: 'Does not match.'
      end

      it 'returns only matching submissions' do
        params = { term: query }
        matching = SubmissionMatch.find_all(params).to_a
        expect(matching).to eq [submission]
      end
    end

    context 'ordering matches' do
      let(:first_user) { Fabricate :user, email: 'c@example.com' }
      let(:second_user) { Fabricate :user, email: 'b@example.com' }
      let(:third_user) { Fabricate :user, email: 'a@example.com' }

      let!(:first_submission) do
        Fabricate :submission, id: 1, user: first_user, offers_count: 20
      end
      let!(:second_submission) do
        Fabricate :submission, id: 2, user: second_user, offers_count: 10
      end
      let!(:third_submission) do
        Fabricate :submission, id: 3, user: third_user, offers_count: 30
      end

      context 'with nothing specified' do
        it 'falls back to defaults' do
          params = {}
          matching = SubmissionMatch.find_all(params).to_a
          expected = [third_submission, second_submission, first_submission]
          expect(matching).to eq expected
        end
      end

      context 'with a sort and direction specified' do
        it 'orders by that sort and direction' do
          params = { sort: 'offers_count', direction: 'asc' }
          matching = SubmissionMatch.find_all(params).to_a
          expected = [second_submission, first_submission, third_submission]
          expect(matching).to eq expected
        end
      end

      context 'when sorting by users.email' do
        let!(:fourth_submission) do
          Fabricate :submission, id: 4, user: first_user
        end

        it 'breaks ties with submission id' do
          params = { sort: 'users.email', direction: 'asc' }
          matching = SubmissionMatch.find_all(params).to_a
          expected = [
            third_submission,
            second_submission,
            fourth_submission,
            first_submission
          ]
          expect(matching).to eq expected
        end
      end
    end
  end
end
