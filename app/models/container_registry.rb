# frozen_string_literal: true

class ContainerRegistry < ApplicationRecord
  has_many :computations, dependent: :destroy
  validates :registry_url,
            uniqueness: true,
            presence: true,
            format: { with: %r{\Ashub:\/\/(([0-9]{1,3}.){3}[0-9]{1,3}\/)?\z} }
end
