# frozen_string_literal: true

module Admin
  class NotesController < ApplicationController
    def create
      @submission = Submission.find(note_params[:submission_id])
      note = Note.new(gravity_user_id: @current_user, **note_params)

      if note.save
        redirect_to admin_submission_path(@submission),
                    notice: 'Note has successfully been created.'
      else
        redirect_to admin_submission_path(@submission),
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
