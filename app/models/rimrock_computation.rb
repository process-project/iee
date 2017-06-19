# frozen_string_literal: true
class RimrockComputation < Computation
  validates :script, presence: true, unless: :created?
  validates :input_path, :output_path, :working_file_name, absence: true

  private

  def created?
    status == 'created'
  end
end
