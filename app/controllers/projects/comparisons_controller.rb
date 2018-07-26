# frozen_string_literal: true

module Projects
  class ComparisonsController < ApplicationController
    before_action :check_pipelines, only: [:index]
    before_action :find_and_authorize, only: [:index]

    TYPES = {
      'estimated_parameters' => 'text',
      'heart_model_output' => 'text',
      'off_mesh' => 'off',
      'graphics' => 'graphics'
    }.freeze

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def index
      # TODO: FIXME the following two lines are not needed when project sync problem is solved
      #             can also enable the Metrics/MethodLength cop again, then
      @project.execute_data_sync(current_user)
      pipelines.reload

      @sources = []
      pipelines.first.computations.select(&:revision).each do |compared_comp|
        compare_to_comp = pipelines.second.computations.select(&:revision).
                          detect { |c| c.pipeline_step == compared_comp.pipeline_step }

        @sources << [compared_comp, compare_to_comp] if compare_to_comp
      end

      @data = { compared: [], not_comparable: [] }
      pipelines.first.outputs.each do |compared|
        compare_to = pipelines.second.outputs.detect { |df| df.similar?(compared) }
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
      @pipelines ||= project.pipelines.where(iid: params[:pipeline_ids]).
                     includes(:outputs, :computations)
    end

    def project
      @project ||= Project.find_by!(project_name: params[:project_id])
    end

    def find_and_authorize
      pipelines.each { |pipeline| authorize(pipeline) }
    end

    def check_pipelines
      if pipelines.size != 2
        redirect_to project_path(@project), alert: I18n.t('projects.comparisons.index.invalid')
      end
    end

    def comparison_data(compared, compare_to)
      viewer = viewer(compared.data_type)

      if viewer == 'text'
        text_data(compared, compare_to)
      elsif viewer == 'off'
        off_data(compared, compare_to)
      elsif viewer == 'graphics'
        graphics_data(compared, compare_to)
      end
    end

    def viewer(data_type)
      TYPES.fetch(data_type) { 'unknown' }
    end

    def text_data(compared, compare_to)
      {
        viewer: 'text',
        data_type: t("data_file.data_types.#{compared.data_type}"),
        compared: text_details(compared),
        compare_to: text_details(compare_to)
      }
    end

    def off_data(compared, compare_to)
      {
        viewer: 'off',
        compared: off_details(compared),
        compare_to: off_details(compare_to)
      }
    end

    def graphics_data(compared, compare_to)
      {
        viewer: 'graphics',
        compared: img_details(compared),
        compare_to: img_details(compare_to)
      }
    end

    def off_details(payload)
      {
        name: payload.name,
        path: payload.url,
        pipeline: payload.output_of.name
      }
    end

    def text_details(payload)
      {
        name: payload.name,
        content: payload.content(current_user),
        pipeline: payload.output_of.name
      }
    end

    def img_details(payload)
      {
        name: payload.name,
        url: payload.url,
        pipeline: payload.output_of.name
      }
    end
  end
end
