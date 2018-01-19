# frozen_string_literal: true

module PipelineStep
  class Cfd < RimrockBase
    DEF = RimrockStep.new('cfd',
                          'eurvalve/cfd',
                          'cfd.sh.erb',
                          [:truncated_off_mesh])

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
