class User < ApplicationRecord
  validates :gravity_user_id, presence: true, uniqueness: true
end
