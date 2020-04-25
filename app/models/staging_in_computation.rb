# frozen_string_literal: true


# TODO: DELETE THIS CLASS -> DO POWERFUL MIGRATION
class StagingInComputation < Computation
  # validates :script, absence: true
  # validates :output_path, presence: true
  # validates :run_mode, presence: true, unless: :created?

  alias_attribute :src_path, :input_path
  alias_attribute :dest_path, :output_path

  private

  def created?
    status == 'created'
  end
end
