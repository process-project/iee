# frozen_string_literal: true

module PipelineStep
  class Segmentation < Base
    DEF = WebdavStep.new('segmentation', [:image])

    def initialize(computation, options = {})
      super(computation, options)
    end

    def self.create(pipeline, params)
      DEF.builder_for(pipeline, params).call
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
