# frozen_string_literal: true

module PipelineStep
  class Rom < RimrockBase
    DEF = RimrockStep.new('rom',
                          'eurvalve/cfd',
                          'rom.sh.erb',
                          [:response_surface])

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
