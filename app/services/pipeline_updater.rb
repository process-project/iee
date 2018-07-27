# frozen_string_literal: true

class PipelineUpdater
  def initialize(computation)
    @computation = computation
  end

  def call
    project = @computation.pipeline.project
    user = @computation.user
    project && user && project.execute_data_sync(user)
    Pipelines::StartRunnable.new(@computation.pipeline).call
  end
end
