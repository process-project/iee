# frozen_string_literal: true

module Patients
  class ComparisonsController < ApplicationController
    before_action :check_pipelines, only: [:show]
    before_action :find_and_authorize, only: [:show]

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def show
      # TODO: FIXME the following two lines are not needed when patient sync problem is solved
      #             can also enable the Metrics/MethodLength cop again, then
      @patient.execute_data_sync(current_user)
      pipelines.reload

      @data = { compared: [], not_comparable: [] }
      pipelines.first.data_files.each do |compared|
        compare_to = pipelines.second.data_files.detect { |df| df.data_type == compared.data_type }
        if compared.comparable? && compare_to.present?
          @data[:compared] << comparison_data(compared, compare_to)
        elsif compare_to.present?
          @data[:not_comparable] << t("data_file.data_types.#{compared.data_type}")
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

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

    def check_pipelines
      if pipelines.size != 2
        redirect_to patient_path(@patient), alert: I18n.t('patients.comparisons.show.invalid')
      end
    end

    # rubocop:disable Metrics/MethodLength
    def comparison_data(compared, compare_to)
      {
        data_type: t("data_file.data_types.#{compared.data_type}"),
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
    # rubocop:enabled Metrics/MethodLength
  end
end
