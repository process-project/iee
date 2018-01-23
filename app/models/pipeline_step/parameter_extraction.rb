# frozen_string_literal: true

module PipelineStep
  class ParameterExtraction < Base
    DEF = RimrockStep.new('parameter_extraction',
                          'eurvalve/parameter-extraction',
                          'parameter_extraction.sh.erb',
                          [:off_mesh])

    def initialize(computation, options = {})
      super(computation, options)
    end

    def runnable?
      DEF.runnable_for?(computation)
    end

    protected

    def runner
      DEF.runner_for(computation, options)
    end
  end
end
