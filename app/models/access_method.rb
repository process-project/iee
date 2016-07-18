class AccessMethod < ApplicationRecord
  has_many :access_policies, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
