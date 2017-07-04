# frozen_string_literal: true

module Patients
  class Base < PatientWebdav
    def initialize(user, patient, options = {})
      super(user, options)
      @patient = patient
    end

    def call
      Patient.transaction { internal_call }
      @patient
    end
  end
end
