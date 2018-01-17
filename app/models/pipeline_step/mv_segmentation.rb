# frozen_string_literal: true

module PipelineStep
  class MvSegmentation < RimrockBase
    DEF = RimrockStep.new('mv_segmentation',
                          'eurvalve/mock-step',
                          'mock.sh.erb')

    def initialize(computation, options = {})
      super(computation, DEF, options)
    end

    def self.create(pipeline, params)
      DEF.builder_for(pipeline, params).call
    end

    def runnable?
      true
    end
  end
end
