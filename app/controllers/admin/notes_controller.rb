# frozen_string_literal: true

module Admin
  class NotesController < ApplicationController
    def create
      note_attrs = note_params.merge(gravity_user_id: @current_user)
      note = Note.new(note_attrs)
      path = admin_submission_path(note.submission)

      if note.save
        redirect_to path, notice: 'Note has successfully been created.'
      else
        redirect_to path,
                    alert:
                      "Could not create note: #{
                        note.errors.full_messages.join(', ')
                      }"
      end
    end

    private

    def note_params
      params.require(:note).permit(:submission_id, :body)
    end
  end
end
