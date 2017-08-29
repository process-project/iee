# frozen_string_literal: true

module PipelineStep
  class Base
    delegate :pipeline, :user, :pipeline_step, to: :computation
    attr_reader :computation

    def initialize(computation, options)
      @computation = computation
      @updater = options.fetch(:updater) { ComputationUpdater }
    end

    def run
      raise 'Required inputs are not available' unless runnable?

      computation.status = :new
      computation.started_at = Time.current

      pre_internal_run
      saved = computation.save
      internal_run
      @updater.new(computation).call if saved

      saved
    end

    def runnable?
      raise 'This method should be implemented by descendent class'
    end

    protected

    def pre_internal_run; end

    def internal_run
      raise 'This method should be implemented by descendent class'
    end
  end
end
