# frozen_string_literal: true

module Patients
  class ComparisonsController < ApplicationController
    before_action :check_pipelines, only: [:show]
    before_action :find_and_authorize, only: [:show]

    TYPES = {
      'estimated_parameters' => 'text',
      'heart_model_output' => 'text',
      'off_mesh' => 'off'
    }.freeze

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def show
      # TODO: FIXME the following two lines are not needed when patient sync problem is solved
      #             can also enable the Metrics/MethodLength cop again, then
      @patient.execute_data_sync(current_user)
      pipelines.reload

      @data = { compared: [], not_comparable: [] }
      pipelines.first.data_files.each do |compared|
        compare_to = pipelines.second.data_files.detect { |df| df.similar?(compared) }
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

    def comparison_data(compared, compare_to)
      viewer = viewer(compared.data_type)

      if viewer == 'text'
        text_data(compared, compare_to)
      elsif viewer == 'off'
        off_data(compared, compare_to)
      end
    end

    def viewer(data_type)
      TYPES.fetch(data_type) { 'unknown' }
    end

    def text_data(compared, compare_to)
      {
        viewer: 'text',
        data_type: t("data_file.data_types.#{compared.data_type}"),
        compared: text_details(compared.name,
                               compared.content(current_user), compared.pipeline.name),
        compare_to: text_details(compare_to.name,
                                 compare_to.content(current_user), compare_to.pipeline.name)
      }
    end

    def off_data(compared, compare_to)
      {
        viewer: 'off',
        compared: off_details(compared.name, compared.url, compared.pipeline.name),
        compare_to: off_details(compare_to.name, compare_to.url, compare_to.pipeline.name)
      }
    end

    def off_details(name, url, pipeline_name)
      { name: name, path: url, pipeline: pipeline_name }
    end

    def text_details(name, content, pipeline_name)
      { name: name, content: content, pipeline: pipeline_name }
    end
  end
end
