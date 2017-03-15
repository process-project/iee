# frozen_string_literal: true
class RimrockComputation < Computation
  validates :script, presence: true
  validates :input_path, :output_path, absence: true
end
