# frozen_string_literal: true
module Patients
  class ComparisonsController < ApplicationController
    before_action :find_and_authorize, only: [:show]

    def show
      if pipelines.size != 2
        redirect_to patient_path(@patient),
                    alert: I18n.t('patients.comparisons.show.invalid')
      end

      # FIXME NOTE: the following two lines are not needed when patient sync problem is solved
      @patient.execute_data_sync(current_user)
      pipelines.reload

      @data = []
      pipelines.first.data_files.each do |compared|
        compare_to = pipelines.second.data_files.detect { |df| df.data_type == compared.data_type }
        if compare_to.present?
          @data << { data_type: t("data_file.data_types.#{compared.data_type}"),
                     compared: {
                       name: compared.name,
                       content: compared.content(current_user),
                       pipeline: compared.pipeline.name
                     },
                     compare_to: {
                       name: compare_to.name,
                       content: compare_to.content(current_user),
                       pipeline: compare_to.pipeline.name
                     }
          }
        end
      end
    end

    private

    def pipelines
      @pipelines ||= patient.pipelines.where(iid: params[:pipeline_ids]).includes(:data_files)
    end

    def patient
      @patient ||= Patient.find(params[:patient_id])
    end

    def find_and_authorize
      pipelines.each { |pipeline| authorize(pipeline) }
    end
  end
end
