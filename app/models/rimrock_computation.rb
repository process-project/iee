# frozen_string_literal: true
class RimrockComputation < Computation
  validates :script, presence: true
  validates :input_path, :output_path, :working_file_name, absence: true

  def run
    Rimrock::StartJob.perform_later(self)
  end
end
