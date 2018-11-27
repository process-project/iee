# frozen_string_literal: true

class PipelineUpdater
  def initialize(computation)
    @computation = computation
  end

  def call
    Pipelines::StartRunnable.new(@computation.pipeline).call
  end
end
