# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Note, type: :model do

  it 'belongs to an author' do
    author = Fabricate(:user, email: "admin@art.sy")
    submission = Fabricate(:submission)
    note = Note.new(submission: submission, created_by: author.id, body: "Im a note")

    expect(note).to be_valid
    expect(note.author.email).to eq "admin@art.sy"
  end
end
