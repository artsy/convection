# frozen_string_literal: true

# This module adds a reload UUID functionality to a model. Without it:
#
# submission = Submission.create!
# submission.uuid # => nil
# submission.reload.uuid # => 03f32677-8c0c-4e86-b722-5ed3d53a087c
#
# With it:
#
# submission = Submission.create!
# submission.uuid # => 03f32677-8c0c-4e86-b722-5ed3d53a087c
#
# See this discussion for details: https://github.com/rails/rails/issues/17605
module ReloadUuid
  extend ActiveSupport::Concern

  included do
    after_commit :reload_uuid, on: :create

    def reload_uuid
      if attributes.has_key? 'uuid'
        self[:uuid] = self.class.where(id: id).pick(:uuid)
      end
    end
  end
end
