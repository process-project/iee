# frozen_string_literal: true

module Pipelines
  class Create < Pipelines::Base
    def initialize(pipeline, params, options = {})
      super(pipeline, options)
      @params = params
    end

    protected

    def internal_call
      @pipeline.save.tap { |saved| post_save if saved }
    rescue Net::HTTPServerException
      @pipeline.errors.
        add(:name,
            I18n.t('activerecord.errors.models.pipeline.create_dav403'))

      raise ActiveRecord::Rollback
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
