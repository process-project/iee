class Group < ActiveRecord::Base
  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :permissions, dependent: :destroy

  validates :name, presence: true
end
