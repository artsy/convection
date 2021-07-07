# frozen_string_literal: true

module Admin
  class NotesController < ApplicationController
    def create
      submission = Submission.find(params.dig(:note, :submission_id))
      if params.dig(:note, :add_note_to_user)
        note = submission.user.notes.new(note_params)
      else
        note = submission.notes.new(note_params)
      end
      path = admin_submission_path(submission)

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
      params.require(:note).permit(:body).merge(gravity_user_id: @current_user)
    end
  end
end
