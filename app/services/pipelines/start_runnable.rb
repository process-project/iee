# frozen_string_literal: true

module Pipelines
  class StartRunnable
    def initialize(pipeline)
      @pipeline = pipeline
    end

    def call
      internal_call if @pipeline.automatic?
    end

    private

    def internal_call
      @pipeline.computations.created.each { |c| c.run if c.runnable? }
    end
  end
end
