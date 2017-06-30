Fabricator(:asset) do
end

Fabricator(:image, from: :asset) do
  asset_type 'image'
  gemini_token { Fabricate.sequence(:gemini_token) { |i| "gemini-#{i}" } }
  image_urls do
    {
      square: 'https://image-square.jpg',
      thumbnail: 'https://image-thumb.jpg',
      large: 'https://image-large.jpg'
    }
  end
end

Fabricator(:unprocessed_image, from: :asset) do
  asset_type 'image'
  gemini_token { Fabricate.sequence(:gemini_token) { |i| "gemini-#{i}" } }
end
