# frozen_string_literal: true

class CreateSubmissionResolver < BaseResolver
  def valid?
    return true if admin? || trusted_application?

    bad_argument_error =
      GraphQL::ExecutionError.new("Can't access createConsignmentSubmission")
    @error = bad_argument_error
    false
  end

  def run
    input = @arguments.to_h['input'] || {}
    params = input.except('clientMutationId').transform_keys(&:underscore)

    client_mutation_id = input['clientMutationId']

    submission =
      SubmissionService.create_submission(params, @context[:current_user])

    OpenStruct.new(
      consignmentSubmission: submission, client_mutation_id: client_mutation_id
    )
  end
end
