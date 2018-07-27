# frozen_string_literal: true

module Pipelines
  class Base < ProjectWebdav
    def initialize(pipeline, options = {})
      super(pipeline.user, options)
      @pipeline = pipeline
    end

    def call
      Pipeline.transaction { internal_call }
      @pipeline
    end
  end
end
