# frozen_string_literal: true

class PipelineUpdater
  def initialize(computation)
    @computation = computation
  end

  def call
    patient = @computation.pipeline.patient
    user = @computation.user
    patient && user && patient.execute_data_sync(user)
  end
end
