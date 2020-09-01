# frozen_string_literal: true

module Pipelines
  class Create
    def initialize(pipeline, params, _options = {})
      @pipeline = pipeline
      @params = params
    end

    def call
      Pipeline.transaction { internal_call }
      @pipeline
    end

    protected

    def internal_call
      @pipeline.save.tap { |saved| post_save if saved }
    end

    private

    def post_save
      create_computations
    end

    def create_computations
      @pipeline.steps.each do |step|
        step.builder_for(@pipeline, step_parameter_values(step.name)).call
      end
    end

    def step_parameter_values(step_name)
      @params.fetch(step_name) { {} }
    end
  end
end
