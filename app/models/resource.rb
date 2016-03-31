class Resource < ActiveRecord::Base
  has_many :permissions, dependent: :destroy

  validates :name, presence: true
  validates :uri, presence: true
end
