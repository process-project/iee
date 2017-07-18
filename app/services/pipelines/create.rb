# frozen_string_literal: true

module Pipelines
  class Create < Pipelines::Base
    protected

    def internal_call
      @pipeline.save
      r_mkdir(@pipeline.working_dir)
      create_computations
    rescue Net::HTTPServerException
      @pipeline.errors.
        add(:name,
            I18n.t('activerecord.errors.models.pipeline.create_dav403'))

      raise ActiveRecord::Rollback
    end

    private

    def create_computations
      Pipeline::STEPS.each do |builder_clazz|
        builder_clazz.new(@pipeline).create
      end
    end
  end
end
