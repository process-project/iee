# frozen_string_literal: true

class ComputationChannel < ApplicationCable::Channel
  def subscribed
    stream_for computation
  end

  def receive(data)
    if data['new_input']
      data_sync!
      ComputationUpdater.new(computation).call
      Pipelines::StartRunnable.new(computation.pipeline).call
    end
  end

  private

  def data_sync!
    Vapor::Application.config.sync_callbacks ||
      computation.pipeline.patient.execute_data_sync(current_user)
  end

  def computation
    Computation.joins(:pipeline).
      find_by(pipelines: { patient_id: params[:patient],
                           iid: params[:pipeline] },
              pipeline_step: params[:computation])
  end
end
