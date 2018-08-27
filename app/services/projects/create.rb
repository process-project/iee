# frozen_string_literal: true

module Projects
  class Create < Projects::Base
    protected

    def internal_call
      if @project.save
        r_mkdir(@project.inputs_dir)
        r_mkdir(@project.pipelines_dir)
      end
    rescue Net::HTTPServerException
      @project.errors.
        add(:project_name,
            I18n.t('activerecord.errors.models.project.create_dav403'))

      raise ActiveRecord::Rollback
    end
  end
end
