class SwaMyCollectionEmailWorker
  include Sidekiq::Worker

  def perform(submission_id)
    BrazeService.send_swa_my_collection_email(submission_id)
  end
end
