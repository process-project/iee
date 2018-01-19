# frozen_string_literal: true

module PipelineStep
  class ValvePlacementX12 < RimrockBase
    DEF = RimrockStep.new('valve_placement_x12',
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
