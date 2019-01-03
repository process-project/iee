# frozen_string_literal: true

class SingularityComputation < Computation
  validates :script, presence: true, unless: :created?
  validates :container_name, presence: true
  validates :registry_url, presence: true
  validates :container_tag, presence: true
end
