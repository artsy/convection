# frozen_string_literal: true

module DashboardReportingQuery
  module Submission
    module_function

    def grouped_by_state
      ::Submission.not_deleted.group(:state).count.symbolize_keys
    end

    def unreviewed_user_submissions(user)
      query = <<-SQL.squish
        SELECT COUNT(*) AS total,
        COUNT(assigned_to IS NULL OR NULL) AS unassigned,
        COUNT(assigned_to = '#{user}' OR NULL) AS self_assigned
        FROM submissions
        WHERE state = 'submitted' AND deleted_at IS NULL
      SQL
      ActiveRecord::Base.connection.execute(query).first.symbolize_keys
    end
  end

  module Offer
    module_function

    def grouped_by_state
      query = <<-SQL.squish
        SELECT COUNT(*) AS total,
        COUNT(state = 'sent' OR NULL) AS sent,
        COUNT(state = 'review' OR NULL) AS review
        FROM offers
      SQL
      ActiveRecord::Base.connection.execute(query).first.symbolize_keys
    end
  end

  module Consignment
    module_function

    def grouped_by_state_and_partner
      query = <<-SQL.squish
        SELECT ps.state,
        COUNT(*) AS total,
        COUNT(p.name LIKE  '%Artsy%' OR NULL) AS artsy_curated,
        COUNT(p.name NOT LIKE  '%Artsy%' OR NULL) AS auction_house
        FROM partner_submissions ps JOIN partners p ON ps.partner_id=p.id
        WHERE accepted_offer_id IS NOT NULL
        GROUP BY ps.state;
      SQL

      ActiveRecord::Base.connection.execute(query).map do |row|
        [
          row['state'].to_sym,
          {
            total: row['total'],
            artsy_curated: row['artsy_curated'],
            auction_house: row['auction_house']
          }
        ]
      end.to_h
    end
  end
end
