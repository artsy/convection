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

    context 'filtering by assigned_to' do
      let!(:unassigned) { Fabricate :submission, assigned_to: nil }
      let!(:alice_assigned) { Fabricate :submission, assigned_to: 'Alice' }
      let!(:betty_assigned) { Fabricate :submission, assigned_to: 'Betty' }

      context 'with a valid assigned username' do
        it 'returns only matching submissions' do
          params = { assigned_to: 'Alice' }
          matching = SubmissionMatch.find_all(params).to_a
          expect(matching).to eq [alice_assigned]
        end
      end

      context 'with a valid assigned username' do
        context 'with published state' do
          let!(:barry_assigned_published) do
            Fabricate :submission, assigned_to: 'Barry', state: 'published'
          end

          let!(:barry_assigned_published_and_accepted) do
            Fabricate :submission, assigned_to: 'Barry', state: 'published'
          end

          let!(:accepted_consignment) do
            Fabricate(
              :consignment,
              submission: barry_assigned_published_and_accepted
            )
          end

          it 'returns only matching submissions without accepted offers' do
            params = { assigned_to: 'Barry', state: 'published' }
            matching = SubmissionMatch.find_all(params).page(1).per(10).to_a
            expect(matching).to eq [barry_assigned_published]
          end
        end

        context 'with approved state' do
          let!(:barry_assigned_approved) do
            Fabricate :submission, assigned_to: 'James', state: 'approved'
          end

          it 'returns only matching submissions without accepted offers' do
            params = { assigned_to: 'James', state: 'approved' }
            matching = SubmissionMatch.find_all(params).to_a
            expect(matching).to eq [barry_assigned_approved]
          end
        end
      end

      context "with 'all' for assigned to" do
        it 'returns all submissions' do
          params = { assigned_to: 'all' }
          matching = SubmissionMatch.find_all(params).to_a
          expect(matching).to eq [betty_assigned, alice_assigned, unassigned]
        end
      end

      context 'with nil for assigned to' do
        it 'returns unassigned submisisons' do
          params = { assigned_to: nil }
          matching = SubmissionMatch.find_all(params).to_a
          expect(matching).to eq [unassigned]
        end
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
        Fabricate :submission, user: first_user, offers_count: 20
      end
      let!(:second_submission) do
        Fabricate :submission, user: second_user, offers_count: 10
      end
      let!(:third_submission) do
        Fabricate :submission, user: third_user, offers_count: 30
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
        let!(:fourth_submission) { Fabricate :submission, user: first_user }

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
