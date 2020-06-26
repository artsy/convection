# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Note, type: :model do
  include ActiveSupport::Testing::TimeHelpers
  let(:author){Fabricate(:user, email: "admin@art.sy")}
  let(:submission){Fabricate(:submission)}
  let(:note){ Note.create(submission: submission, created_by: author.id, body: "Im a note") }
  

  it 'belongs to an author' do
    note = Note.new(submission: submission, created_by: author.id, body: "Im a note")

    expect(note).to be_valid
    expect(note.author.email).to eq "admin@art.sy"
  end

  context '#byline' do
    after(:each) { travel_back }
    it 'if there is an author' do
      travel_to Time.zone.local(2004, 11, 24, 0o1, 0o4, 44) 
      note = Note.create(submission: submission, created_by: author.id, body: "Im a note")
      
      expect(note.byline).to eq("admin@art.sy - November 24, 2004 01:04")
    end
    it 'if the author is missing' do
      travel_to Time.zone.local(2004, 11, 24, 0o1, 0o4, 44)
      note = Note.create(submission: submission, created_by: nil, body: "Im a note")
      
      expect(note.byline).to eq("November 24, 2004 01:04")
    end
    it 'if the note was updated' do
      travel_to Time.zone.local(2004, 11, 24, 0o1, 0o4, 44)
      note = Note.create(submission: submission, created_by: author.id, body: "Im a note")
      travel_to Time.zone.local(2012, 12, 21, 0o1, 0o4, 44)
      note.update(body: "I'm* a note")
          
          expect(note.byline).to eq("admin@art.sy - Updated December 21, 2012 01:04")
    end
  end
end
