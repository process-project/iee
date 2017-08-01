# frozen_string_literal: true

module Patients
  module Pipelines
    class ComputationsController < ApplicationController
      before_action :find_and_authorize

      def show
        # TODO: FIXME the following two lines are not needed when patient
        #             sync problem is solved
        @patient.execute_data_sync(current_user)
        prepare_to_show_computation

        if request.xhr?
          render partial: 'patients/pipelines/computations/show', layout: false,
                 locals: {
                   patient: @patient, pipeline: @pipeline, refresh: @refresh,
                   computation: @computation, computations: @computations, proxy: @proxy
                 }
        end
      end

      def update
        @computation.assign_attributes(permitted_attributes(@computation))
        run_computation
      end

      private

      def run_computation
        if @computation.runnable? && @computation.run
          redirect_to patient_pipeline_computation_path(@patient, @pipeline, @computation),
                      notice: I18n.t('computations.update.started')
        else
          @computation.status = @computation.status_was
          prepare_to_show_computation
          render :show, status: :bad_request,
                        notice: I18n.t('computations.update.not_runnable')
        end
      end

      def find_and_authorize
        @computation = Computation.
                       joins(pipeline: :patient).
                       find_by(pipelines: { patient_id: params[:patient_id],
                                            iid: params[:pipeline_id] },
                               pipeline_step: params[:id])
        @pipeline = @computation.pipeline
        @patient = @pipeline.patient

        authorize(@pipeline)
      end

      def prepare_to_show_computation
        @computations = @pipeline.computations.order(:created_at)
        @refresh = @computations.any?(&:active?)
        @proxy = Proxy.new(current_user)

        repo = Rails.application.
               config_for('eurvalve')['git_repos'][@computation.pipeline_step]
        @versions = Gitlab::Versions.new(repo).call if repo
      end
    end
  end
end
