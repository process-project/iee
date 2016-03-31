class Action < ActiveRecord::Base
  has_many :permissions, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
