# frozen_string_literal: true

Fabricator(:asset)

Fabricator(:image, from: :asset) do
  asset_type "image"
  gemini_token { Fabricate.sequence(:gemini_token) { |i| "gemini-#{i}" } }
  image_urls do
    Fabricate.sequence(:gemini_token) do |i|
      {
        square: "https://placekitten.com/#{i}/#{i}.jpg",
        thumbnail: "https://placekitten.com/#{i}/#{i}.jpg",
        large: "https://placekitten.com/#{i}/#{i}.jpg"
      }
    end
  end
end

Fabricator(:unprocessed_image, from: :asset) do
  asset_type "image"
  gemini_token { Fabricate.sequence(:gemini_token) { |i| "gemini-#{i}" } }
end

Fabricator(:additional_file, from: :asset) do
  asset_type "additional_file"
  s3_bucket "bucket"
  s3_path "path"
  filename "filename.pdf"
end
