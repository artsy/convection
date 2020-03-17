# frozen_string_literal: true

class AddAssetToSubmissionResolver < BaseResolver
  def valid?
    true
  end

  def run
    input = @arguments.to_h['input'] || {}
    params = input.except('clientMutationId').transform_keys(&:underscore)
    params['asset_type'] ||= 'image'

    client_mutation_id = input['clientMutationId']

    submission = Submission.find_by(id: params['submission_id'])
    unless submission
      raise(GraphQL::ExecutionError, 'Submission from ID Not Found')
    end

    matching_user = submission.user&.gravity_user_id == @context[:current_user]

    unless matching_user || admin?
      raise(GraphQL::ExecutionError, 'Submission from ID Not Found')
    end

    asset = submission.assets.create!(params)
    SubmissionService.notify_user(submission.id) if submission.submitted?

    OpenStruct.new(asset: asset, client_mutation_id: client_mutation_id)
  end
end
