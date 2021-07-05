# frozen_string_literal: true

require 'rails_helper'
require 'support/gravity_helper'

RSpec.describe Note, type: :model do
  describe ".notes_with_assigned_partner" do
    subject { Note.notes_with_assigned_partner }

    let(:note) { Note.create(note_attrs) }

    context 'with a assigned to partner note' do
      let(:note_attrs) do
        {
          body: 'This is a note',
          gravity_user_id: '1',
          assign_with_partner: true
        }
      end

      it { is_expected.to include(note) }
    end

    context 'without a assigned to partner note' do
      let(:note_attrs) do
        {
          body: 'This is a note',
          gravity_user_id: '1',
          assign_with_partner: false
        }
      end

      it { is_expected.to_not include(note) }
    end
  end

  describe 'author' do
    let(:submission) { Fabricate(:submission) }

    let(:note_attrs) do
      {
        body: 'This is a note',
        gravity_user_id: gravity_user_id,
        submission: submission
      }
    end

    before { stub_gravity_root }

    context 'with a valid gravity user id' do
      let(:gravity_user_id) { 'abc123' }

      before do
        mocked_user_data = {
          email: 'buster@example.com', id: gravity_user_id, name: 'Buster Bluth'
        }

        @stub = stub_gravity_user(mocked_user_data)
      end

      it 'returns that author' do
        note = Note.create(note_attrs)
        expect(note.author.email).to eq 'buster@example.com'
        expect(note.author.name).to eq 'Buster Bluth'
      end
    end

    context 'with a failed request for the gravity user' do
      let(:gravity_user_id) { 'invalid' }

      before do
        user_url = "#{Convection.config.gravity_api_url}/users/invalid"
        stub_request(:get, user_url).to_raise(Faraday::ResourceNotFound)
      end

      it 'returns nil' do
        note = Note.create(note_attrs)
        expect(note.author).to eq nil
      end
    end

    context 'without a gravity user id' do
      let(:gravity_user_id) { nil }

      it 'returns nil' do
        note = Note.new(note_attrs)
        expect(note.author).to eq nil
      end
    end
  end
end
