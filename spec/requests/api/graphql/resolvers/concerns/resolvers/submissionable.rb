# frozen_string_literal: true

require 'rails_helper'

describe 'Resolvers::Submissionable' do
  let(:submission) { Fabricate :submission }

  let(:dummy_class) do
    Class.new do
      include Resolvers::Submissionable

      def initialize(arguments)
        @arguments = arguments
      end
    end
  end

  describe '#submission' do
    context 'when default submission_id / external_submission_id' do
      it 'returns nil for non-existing submission' do
        expect(dummy_class.new(id: submission.id + 1).submission).to be_nil
        expect(
          dummy_class.new(external_id: SecureRandom.uuid).submission
        ).to be_nil
      end

      it 'returns correct submission when passing correct arguments' do
        expect(dummy_class.new(id: submission.id).submission).to eq(submission)
        expect(
          dummy_class.new(external_id: submission.external_id).submission
        ).to eq(submission)
      end
    end

    context 'when overwriting submission_id / external_submission_id' do
      let(:dummy_class) do
        Class.new do
          include Resolvers::Submissionable

          def initialize(arguments)
            @arguments = arguments
          end

          def submission_id
            @arguments[:sid]
          end

          def external_submission_id
            @arguments[:esid]
          end
        end
      end

      it 'returns correct submission when passing correct arguments' do
        expect(dummy_class.new(sid: submission.id).submission).to eq(submission)
        expect(dummy_class.new(esid: submission.external_id).submission).to eq(
          submission
        )
      end
    end
  end

  describe 'check_submission_presence!' do
    context 'when submission exists' do
      it "doesn't fail" do
        expect {
          dummy_class.new(id: submission.id + 1).check_submission_presence!
        }.to raise_error(GraphQL::ExecutionError, 'Submission Not Found')
      end
    end

    context "when submission doesn't exist" do
      it 'fails' do
        expect {
          dummy_class.new(id: submission.id).check_submission_presence!
        }.not_to raise_error
      end
    end
  end

  describe 'valid?' do
    context 'ids presence' do
      context 'when both ids are not passed' do
        it 'is not valid' do
          class_instance = dummy_class.new({})
          expect(class_instance.valid?).to eq(false)
        end
      end

      context 'when id or external_id is passed' do
        it 'is valid' do
          class_instance = dummy_class.new(id: submission.id)
          expect(class_instance.valid?).to eq(true)

          class_instance = dummy_class.new(external_id: submission.external_id)
          expect(class_instance.valid?).to eq(true)
        end
      end
    end
  end
end
