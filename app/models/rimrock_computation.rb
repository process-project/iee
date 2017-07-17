# frozen_string_literal: true

class RimrockComputation < Computation
  validates :script, presence: true, unless: :created?
  validates :input_path, :output_path, :working_file_name, absence: true

  # TODO: this method should be remove after
  # https://gitlab.com/eurvalve/vapor/issues/237 is resolved
  def revision
    'master'
  end

  private

  def created?
    status == 'created'
  end
end
