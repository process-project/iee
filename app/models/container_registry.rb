# frozen_string_literal: true

class ContainerRegistry < ApplicationRecord
  validates :registry_url, uniqueness: true, presence: false
end
