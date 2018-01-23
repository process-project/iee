# frozen_string_literal: true

module PipelineStep
  class Rom < Base
    DEF = RimrockStep.new('rom',
                          'eurvalve/cfd',
                          'rom.sh.erb',
                          [:response_surface])

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
