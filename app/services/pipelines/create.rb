# frozen_string_literal: true
module Pipelines
  class Create < Base
    protected

    def internal_call
      @pipeline.save
      r_mkdir(@pipeline.working_dir)
    rescue Net::HTTPServerException
      @pipeline.errors.
        add(:name,
            I18n.t('activerecord.errors.models.pipeline.create_dav403'))

      raise ActiveRecord::Rollback
    end
  end
end
