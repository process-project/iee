# frozen_string_literal: true

module Api
  class PatientsController < Api::ApplicationController
    before_action :find_and_authorize, only: [:show, :destroy]

    def index
      authorize(Patient)
      patients = policy_scope(Patient).includes(:pipelines)

      render json: PatientSerializer.new(patients)
    end

    def show
      render json: PatientSerializer.new(@patient)
    end

    def create
      new_patient = Patient.new(permitted_attributes(Patient))
      authorize(new_patient)

      patient = Patients::Create.new(current_user, new_patient).call
      if patient.errors.empty?
        patient.execute_data_sync(current_user)

        render json: PatientSerializer.new(patient), status: :created
      else
        api_error status: 400, errors: patient.errors
      end
    end

    def destroy
      if Patients::Destroy.new(current_user, @patient).call
        head :no_content
      else
        api_error error: I18n.t('patients.destroy.failure',
                                case_number: @patient.case_number)
      end
    end

    private

    def find_and_authorize
      @patient = policy_scope(Patient).find_by!(case_number: params[:id])
      authorize(@patient)
    end
  end
end
