# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Note, type: :model do
  let(:author) { Fabricate(:user, email: 'admin@art.sy') }
  let(:submission) { Fabricate(:submission) }

  it 'belongs to an author' do
    note =
      Note.create(submission: submission, author: author, body: 'Im a note')

    expect(note).to be_valid
    expect(note.author.email).to eq 'admin@art.sy'
  end

  it 'belongs to nil if the gravity_user_id is nil' do
    note =
      Note.new(submission: submission, gravity_user_id: nil, body: 'Im a note')
    expect(note).to be_valid
    expect(note.author).to be_nil
  end
end
