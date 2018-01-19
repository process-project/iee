# frozen_string_literal: true

module PipelineStep
  class HaemodynamicComparison < RimrockBase
    DEF = RimrockStep.new('haemodynamic_comparison',
                          'eurvalve/mock-step',
                          'mock.sh.erb')

    def initialize(computation, options = {})
      super(computation, DEF, options)
    end

    def self.create(pipeline, params)
      DEF.builder_for(pipeline, params).call
    end

    def runnable?
      DEF.runnable_for?(computation)
    end
  end
end
