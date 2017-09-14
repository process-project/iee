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
      r_mkdir(@pipeline.working_dir)
      create_computations
    end

    def create_computations
      Pipeline::FLOWS[@pipeline.flow.to_sym].each do |builder_class|
        builder_class.create(@pipeline, step_params(builder_class))
      end
    end

    def step_params(builder_class)
      @params.fetch(builder_class::STEP_NAME) { {} }
    end
  end
end
