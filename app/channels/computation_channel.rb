# frozen_string_literal: true

class ComputationChannel < ApplicationCable::Channel
  def subscribed
    @staging_logger ||= Logger.new(Rails.root.join('log', 'debug.log'))
    @staging_logger.debug("subscribe in computation channel")

    stream_for computation
  end

  def receive(data)
    @staging_logger ||= Logger.new(Rails.root.join('log', 'debug.log'))
    @staging_logger.debug("recieve in computation channel outside if")

    if data['new_input']
      @staging_logger ||= Logger.new(Rails.root.join('log', 'debug.log'))
      @staging_logger.debug("recieve in computation channel inside if")

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
