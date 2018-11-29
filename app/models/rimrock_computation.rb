# frozen_string_literal: true

class RimrockComputation < Computation
  validates :script, presence: true, unless: :created?
  validates :input_path, :output_path, :working_file_name, :run_mode, absence: true
  validates :tag_or_branch, presence: true, unless: -> { created? && automatic? }
end
