# frozen_string_literal: true

class CloudComputation < Computation
  validates :script, presence: true, unless: :created?
  validates :input_path, :output_path, :working_file_name, absence: true
  validates :tag_or_branch, presence: true, unless: :created?

  private

  def created?
    status == 'created'
  end
end
