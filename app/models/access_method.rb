class AccessMethod < ActiveRecord::Base
  has_many :access_policies, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
