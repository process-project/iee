# frozen_string_literal: true

module Pipelines
  class StepsConfig
    def initialize(flow, force_reload: false)
      @steps = Flow.steps(flow)
      @force_reload = force_reload
    end

    def call
      Hash[@steps.map { |step| [step.name, step.config(@force_reload)] }]
    end
  end
end
