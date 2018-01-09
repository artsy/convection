module ReferenceId
  extend ActiveSupport::Concern

  included do
    before_create :create_reference_id
  end

  def create_reference_id
    loop do
      self.reference_id = SecureRandom.hex(5)
      break unless self.class.exists?(reference_id: reference_id)
    end
  end
end
