# frozen_string_literal: true

module PipelineStep
  class Cfd < RimrockBase
    DEF = RimrockStep.new('cfd', 'eurvalve/cfd', 'cfd.sh.erb')

    def initialize(computation, options = {})
      super(computation, DEF, options)
    end

    def self.create(pipeline, params)
      DEF.builder_for(pipeline, params).call
    end

    def runnable?
      pipeline.data_file(:truncated_off_mesh)
    end
  end
end
