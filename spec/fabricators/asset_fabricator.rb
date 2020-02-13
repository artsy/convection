# frozen_string_literal: true

Fabricator(:asset) {}

Fabricator(:image, from: :asset) do
  asset_type 'image'
  gemini_token { Fabricate.sequence(:gemini_token) { |i| "gemini-#{i}" } }
  image_urls do
    Fabricate.sequence(:gemini_token) do |i|
      {
        square: "https://image-square-#{i}.jpg",
        thumbnail: "https://image-thumb-#{i}.jpg",
        large: "https://image-large-#{i}.jpg"
      }
    end
  end
end

Fabricator(:unprocessed_image, from: :asset) do
  asset_type 'image'
  gemini_token { Fabricate.sequence(:gemini_token) { |i| "gemini-#{i}" } }
end
