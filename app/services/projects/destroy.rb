# frozen_string_literal: true

module Projects
  class Destroy < Base
    def call
      !super.persisted?
    end

    protected

    def internal_call
      @project.destroy
      delete(@project.working_dir)
    rescue Net::HTTPServerException
      raise ActiveRecord::Rollback
    end
  end
end
