# frozen_string_literal: true

module PipelineStep
  class ParameterExtraction < RimrockBase
    DEF = RimrockStep.new('parameter_extraction',
                          'eurvalve/parameter-extraction',
                          'parameter_extraction.sh.erb')

    def initialize(computation, options = {})
      super(computation, DEF, options)
    end

    def self.create(pipeline, params)
      DEF.builder_for(pipeline, params).call
    end

    def runnable?
      pipeline.data_file(:off_mesh)
    end
  end
end
