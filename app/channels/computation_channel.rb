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

  def computation
    Computation.joins(:pipeline).
      find_by(pipelines: { project_id: params[:project],
                           iid: params[:pipeline] },
              pipeline_step: params[:computation])
  end

  def data_sync!
    computation.pipeline.project.execute_data_sync(current_user)
  end
end
