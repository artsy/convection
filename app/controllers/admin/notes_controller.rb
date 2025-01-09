# frozen_string_literal: true

module Admin
  class NotesController < ApplicationController
    def create
      submission = Submission.find(params.dig(:note, :submission_id))
      note =
        if params.dig(:note, :add_note_to_user) == "0"
          submission.notes.new(note_params)
        else
          submission.user&.notes&.new(note_params)
        end
      path = admin_submission_path(submission)

      if note&.save
        redirect_to path, notice: "Note has successfully been created."
      else
        redirect_to path,
          alert:
            "Could not create note: #{
                        note&.errors&.full_messages&.join(", ") ||
                          "User does not exist"
                      }"
      end
    end

    def authorized_artsy_token?(token)
      ArtsyAdminAuth.valid?(token, [ArtsyAdminAuth::CONSIGNMENTS_REPRESENTATIVE])
    end

    private

    def note_params
      params.require(:note).permit(:body).merge(gravity_user_id: @current_user)
    end
  end
end
