# frozen_string_literal: true

module PipelineStep
  class Base
    delegate :pipeline, :user, :pipeline_step, to: :computation
    attr_reader :computation, :options

    def initialize(computation, options)
      @computation = computation
      @options = options
      @updater = options.fetch(:updater) { ComputationUpdater }
    end

    def run
      raise 'Required inputs are not available' unless runnable?

      runner.call
    end

    def runnable?
      raise 'This method should be implemented by descendent class'
    end

    protected

    def pre_internal_run; end

    def runner
      raise 'This method should be implemented by descendent class'
    end
  end
end
