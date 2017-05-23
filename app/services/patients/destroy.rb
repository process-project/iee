# frozen_string_literal: true
module Patients
  class Destroy < Base
    def call
      !super.persisted?
    end

    protected

    def internal_call
      @patient.destroy
      delete(@patient.case_number)
    rescue Net::HTTPServerException
      raise ActiveRecord::Rollback
    end
  end
end
