# frozen_string_literal: true

class SingularityComputation < Computation
  validates :script, presence: true, unless: :created?
  validates :container_name, presence: true
  validates :container_tag, presence: true
  validates :container_registry, presence: true
end
