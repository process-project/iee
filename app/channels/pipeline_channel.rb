# frozen_string_literal: true

class PipelineChannel < ApplicationCable::Channel
  def subscribed
    stream_for computation
  end

  def receive(data)
    if data['new_input']
      data_sync!
      ComputationUpdater.new(computation).call
    end
  end

  private

  def computation
    Computation.joins(:pipeline).
      find_by(pipelines: { patient_id: params[:patient],
                           iid: params[:pipeline] },
              pipeline_step: params[:computation])
  end

  def data_sync!
    computation.pipeline.patient.execute_data_sync(current_user)
  end
end
