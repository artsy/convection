class MyCollectionArtworksWorker
  include Sneakers::Worker

  from_queue "convection_my_collection_artworks",
    exchange: "my_collection_artworks",
    exchange_type: :topic,
    routing_key: ["my_collection_artwork.updated"]

  def work_with_params(message, delivery_info, _metadata)
    payload = JSON.parse(message, symbolize_names: true)
    logger.info("RABBITMQ: [MyCollectionArtworksWorker] received a message: routing key - #{delivery_info[:routing_key]}")

    case delivery_info[:routing_key]
    when "my_collection_artwork.updated"
      MyCollectionArtworkUpdatedService.new(payload).notify_admin!
    else
      logger.info("RABBITMQ: [MyCollectionArtworksWorker] ignoring a message: routing key - #{delivery_info[:routing_key]}")
    end

    ack!
  end
end
