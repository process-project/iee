# frozen_string_literal: true

class RimrockComputation < Computation
  validates :script, presence: true, unless: :created?
  validates :input_path, :output_path, :working_file_name, :run_mode, absence: true
  validates :tag_or_branch, presence: true, unless: :created?

  def configured?
    super && tag_or_branch.present?
  end
end
