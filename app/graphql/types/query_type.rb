# frozen_string_literal: true

module Types
  class QueryType < GraphQL::Schema::Object
    field :offer, OfferType, null: true do
      description 'Get an Offer'

      argument :id, ID, required: true

      argument :gravity_partner_id, ID, required: false do
        description 'Return offers for the given partner'
      end
    end

    def offer(arguments = {})
      query_options = { arguments: arguments, context: context, object: object }
      resolver = OfferResolver.new(**query_options)
      raise resolver.error unless resolver.valid?

      resolver.run
    end

    field :offers, OfferConnectionType, null: true, connection: true do
      description 'List offers'

      argument :gravity_partner_id, ID, required: true do
        description 'Return offers for the given partner'
      end

      argument :states, [String], required: false do
        description 'Return only offers with matching states'
      end

      argument :sort,
               OfferSortType,
               required: false,
               prepare: OfferSortType.prepare do
        description 'Return offers sorted this way'
      end
    end

    def offers(arguments = {})
      query_options = { arguments: arguments, context: context, object: object }
      resolver = OffersResolver.new(**query_options)
      raise resolver.error unless resolver.valid?

      resolver.run
    end

    field :submission, SubmissionType, null: true do
      description 'Get a Submission'
      argument :id, ID, required: false
      argument :external_id, ID, required: false
      argument :sessionID, String, required: false
    end

    def submission(arguments)
      query_options = { arguments: arguments, context: context, object: object }
      resolver = SubmissionResolver.new(**query_options)
      raise resolver.error unless resolver.valid?

      resolver.run
    end

    field :submissions,
          SubmissionConnectionType,
          null: true,
          connection: true,
          max_page_size: 100 do
      description 'Filter all submission'

      argument :ids, [ID], required: false do
        description 'Get all submissions with these IDs'
      end

      argument :user_id, [ID], required: false do
        description 'Get all submissions with these user IDs'
      end

      argument :available, Boolean, required: false do
        description 'If true return only available submissions'
      end

      argument :sort,
               SubmissionSortType,
               required: false,
               prepare: SubmissionSortType.prepare do
        description 'Return submissions sorted this way'
      end

      argument :filterByCategory, CategoryType, required: false do
        description 'Get submissions filtered by category'
      end
    end

    def submissions(arguments = {})
      query_options = { arguments: arguments, context: context, object: object }
      resolver = SubmissionsResolver.new(**query_options)
      raise resolver.error unless resolver.valid?

      resolver.run
    end

    field :consignments,
          ConsignmentConnectionType,
          null: true,
          connection: true,
          max_page_size: 100 do
      description 'Sold or bought-in consignments'

      argument :gravity_partner_id, ID, required: true do
        description 'Return sold or bought-in consignments for the given partner'
      end

      argument :sort,
               ConsignmentSortType,
               required: false,
               prepare: ConsignmentSortType.prepare do
        description 'Return consignments sorted by input (default sort by id)'
      end
    end

    def consignments(arguments = {})
      query_options = { arguments: arguments, context: context, object: object }
      resolver = ConsignmentsResolver.new(**query_options)
      raise resolver.error unless resolver.valid?

      resolver.run
    end
  end
end
