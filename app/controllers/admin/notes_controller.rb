# frozen_string_literal: true

module Admin
  class NotesController < ApplicationController
    def create
      @submission = Submission.find(note_params[:submission_id]) # require 'pry'; binding.pry
      note = Note.create(gravity_user_id: @current_user, **note_params) # This doesn't actually seem to render in our layout.
      unless note.persisted?
        flash[:notice] =
          "Could not create note: #{note.errors.full_messages.join(', ')}"
      end

      redirect_to admin_submission_path(@submission)
    end

    private

    def note_params
      params.require(:note).permit(:submission_id, :body)
    end
  end
end
