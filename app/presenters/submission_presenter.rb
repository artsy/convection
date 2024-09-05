class SubmissionPresenter < SimpleDelegator
  attr_reader :access_token

  def initialize(submission, access_token)
    @access_token = access_token

    super(submission)
  end

  def condition
    my_collection_data.dig(:data, :artwork, :condition, :displayText)
  end

  def condition_description
    my_collection_data.dig(:data, :artwork, :condition, :description)
  end

  def is_framed?
    my_collection_data.dig(:data, :artwork, :isFramed) ? "Yes" : "No"
  end

  def framed_height
    my_collection_data.dig(:data, :artwork, :framedHeight)
  end

  def framed_width
    my_collection_data.dig(:data, :artwork, :framedWidth)
  end

  def framed_depth
    my_collection_data.dig(:data, :artwork, :framedDepth)
  end

  def framed_metric
    my_collection_data.dig(:data, :artwork, :framedMetric)
  end

  private

  def my_collection_data
    @my_collection_data ||= Metaql::Schema.execute(
      query: my_collection_data_query,
      access_token: access_token,
      variables: {
        id: my_collection_artwork_id
      }
    )
  end

  def my_collection_data_query
    <<~GQL
      query artworkDetails($id: String!) {
        artwork(id: $id){
          condition {
            displayText
            description
          }
          isFramed
          framedHeight
          framedWidth
          framedDepth
          framedMetric
        }
      }
    GQL
  end
end
