# frozen_string_literal: true

module Pipelines
  class StepsConfig
    def initialize(flow, force_reload: false)
      @steps = Flow.steps(flow)
      @force_reload = force_reload
    end

    def call
      Hash[@steps.map { |step| [step.name, config(step)] }]
    end

    private

    def config(step)
      # Can be extended by other step types
      {
        parameters: parameters(step)
      }
    end

    def parameters(step)
      step.parameters
    end
  end
end
