# frozen_string_literal: true
module Pipelines
  class Destroy < Base
    def call
      !super.persisted?
    end

    protected

    def internal_call
      @pipeline.destroy
      delete(pipeline_path)
    rescue Net::HTTPServerException
      raise ActiveRecord::Rollback
    end
  end
end
