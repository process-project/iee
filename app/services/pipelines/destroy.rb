# frozen_string_literal: true

module Pipelines
  class Destroy
    def initialize(pipeline, _options = {})
      @pipeline = pipeline
    end

    def call
      Pipeline.transaction { internal_call }
      !@pipeline.persisted?
    end

    protected

    def internal_call
      @pipeline.destroy
    end
  end
end
