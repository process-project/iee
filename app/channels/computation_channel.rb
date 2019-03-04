# frozen_string_literal: true

class ComputationChannel < ApplicationCable::Channel
  def subscribed
    stream_for computation
  end

  def receive(data)
    if data['new_input'] && callbacks_turned_off
      computation.pipeline.patient.execute_data_sync(current_user)
      ComputationUpdater.new(computation).call
      Pipelines::StartRunnable.new(computation.pipeline).call
    end
  end

  private

  def callbacks_turned_off
    !Vapor::Application.config.sync_callbacks
  end

  def computation
    Computation.joins(:pipeline).
      find_by(pipelines: { patient_id: params[:patient],
                           iid: params[:pipeline] },
              pipeline_step: params[:computation])
  end
end
