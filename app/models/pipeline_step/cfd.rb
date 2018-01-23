# frozen_string_literal: true

module PipelineStep
  class Cfd < Base
    DEF = RimrockStep.new('cfd',
                          'eurvalve/cfd',
                          'cfd.sh.erb',
                          [:truncated_off_mesh])

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
