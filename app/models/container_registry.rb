# frozen_string_literal: true

class ContainerRegistry < ApplicationRecord
  has_many :computations
  validates :registry_url, uniqueness: true, presence: false
end
