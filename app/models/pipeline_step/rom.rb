# frozen_string_literal: true

module PipelineStep
  class Rom < RimrockBase
    DEF = RimrockStep.new('rom', 'eurvalve/cfd', 'rom.sh.erb')

    def initialize(computation, options = {})
      super(computation, DEF, options)
    end

    def self.create(pipeline, params)
      DEF.builder_for(pipeline, params).call
    end

    def runnable?
      pipeline.data_file(:response_surface)
    end
  end
end
