class Resource < ActiveRecord::Base
  has_many :permissions, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :uri, presence: true, uniqueness: true
end
