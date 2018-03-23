module Types
  CategoryType = GraphQL::EnumType.define do
    name 'Category'
    value('PAINTING', nil, value: 'Painting')
    value('SCULPTURE', nil, value: 'Sculpture')
    value('PHOTOGRAPHY', nil, value: 'Photography')
    value('PRINT', nil, value: 'Print')
    value('DRAWING_COLLAGE_OR_OTHER_WORK_ON_PAPER', nil, value: 'Drawing, Collage or other Work on Paper')
    value('MIXED_MEDIA', nil, value: 'Mixed Media')
    value('PERFORMANCE_ART', nil, value: 'Performance Art')
    value('INSTALLATION', nil, value: 'Installation')
    value('VIDEO_FILM_ANIMATION', nil, value: 'Video/Film/Animation')
    value('ARCHITECTURE', nil, value: 'Architecture')
    value('FASHION_DESIGN_AND_WEARABLE_ART', nil, value: 'Fashion Design and Wearable Art')
    value('JEWELRY', nil, value: 'Jewelry')
    value('DESIGN_DECORATIVE_ART', nil, value: 'Design/Decorative Art')
    value('TEXTILE_ARTS', nil, value: 'Textile Arts')
    value('OTHER', nil, value: 'Other')
  end
end
