# frozen_string_literal: true

module Admin
  class NotesController < ApplicationController
    def create
      submission = Submission.find(params.dig(:note, :submission_id))
      note = submission.notes.new(note_params)
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
      params.require(:note).permit(:body, :assign_with_partner).merge(gravity_user_id: @current_user)
    end
  end
end
