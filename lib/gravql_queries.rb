class GravqlQueries
  PARTNER_DETAILS_QUERY = %|
    query partnersDetails($ids: [ID]!){
      partners(ids: $ids){
        id
        given_name
      }
    }
  |.freeze
end
