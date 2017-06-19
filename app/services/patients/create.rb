# frozen_string_literal: true
module Patients
  class Create < Patients::Base
    protected

    def internal_call
      @patient.save
      r_mkdir(@patient.inputs_dir)
      r_mkdir(@patient.pipelines_dir)
    rescue Net::HTTPServerException
      @patient.errors.
        add(:case_number,
            I18n.t('activerecord.errors.models.patient.create_dav403'))

      raise ActiveRecord::Rollback
    end
  end
end
