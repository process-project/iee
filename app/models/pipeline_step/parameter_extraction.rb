# frozen_string_literal: true

module PipelineStep
  class ParameterExtraction < RimrockBase
    DEF = RimrockStep.new('parameter_extraction',
                          'eurvalve/parameter-extraction',
                          'parameter_extraction.sh.erb',
                          [:off_mesh])

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
