# frozen_string_literal: true
module Patients
  class ComparisonsController < ApplicationController
    before_action :find_and_authorize, only: [:show]

    def show
      if pipelines.size != 2
        redirect_to patient_path(@patient),
                    alert: I18n.t('patients.comparisons.show.invalid')
      end
      @patient.execute_data_sync(current_user)
    end

    private

    def pipelines
      @pipelines ||= patient.pipelines.where(iid: params[:pipeline_ids])
    end

    def patient
      @patient ||= Patient.find(params[:patient_id])
    end

    def find_and_authorize
      pipelines.each { |pipeline| authorize(pipeline) }
    end
  end
end
