# frozen_string_literal: true

class ScriptedComputation < Computation
  validates :script, presence: true, unless: :created?
  validates :input_path, :output_path, :working_file_name, absence: true
  validates :tag_or_branch, presence: true, unless: :created?
  validates :deployment, presence: true, unless: :created?

  def runnable?
    step.input_present_for?(pipeline) &&
      tag_or_branch.present? &&
      deployment.present?
  end

  private

  def created?
    status == 'created'
  end
end
