# frozen_string_literal: true
class AccessMethod < ApplicationRecord
  has_many :access_policies, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def self.names_exist?(names)
    AccessMethod.where(name: names).count == names.length
  end
end
