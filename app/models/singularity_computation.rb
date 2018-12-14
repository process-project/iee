# frozen_string_literal: true

class SingularityComputation < Computation
  validates :script, presence: true, unless: :created?
end
