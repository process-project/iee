# frozen_string_literal: true

module Pipelines
  class Base
    def initialize(pipeline, options = {})
      @pipeline = pipeline
    end

    def call
      Pipeline.transaction { internal_call }
      @pipeline
    end
  end
end
