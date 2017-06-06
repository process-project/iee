# frozen_string_literal: true
module Patients
  class Create < Base
    protected

    def internal_call
      @patient.save
      r_mkdir("#{@patient.case_number}/inputs")
      r_mkdir("#{@patient.case_number}/pipelines")
    rescue Net::HTTPServerException
      @patient.errors.
        add(:case_number,
            I18n.t('activerecord.errors.models.patient.create_dav403'))

      raise ActiveRecord::Rollback
    end
  end
end