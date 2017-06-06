# frozen_string_literal: true
module PipelineStep
  class Base
    attr_reader :pipeline, :user, :pipeline_step

    def initialize(pipeline, pipeline_step)
      @pipeline = pipeline
      @pipeline_step = pipeline_step
    end

    def run
      raise 'Required inputs are not available' unless runnable?
      internal_run

      computation
    end

    def runnable?
      raise 'This method should be implemented by descendent class'
    end

    protected

    def user
      pipeline.user
    end

    def internal_run
      raise 'This method should be implemented by descendent class'
    end

    def computation
      @computation ||= pipeline.computations.find_by(pipeline_step: pipeline_step) || create
    end
  end
end
