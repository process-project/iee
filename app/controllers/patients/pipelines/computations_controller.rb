# frozen_string_literal: true

module Patients
  module Pipelines
    class ComputationsController < ApplicationController
      before_action :lookup_repo
      before_action :find_and_authorize

      # rubocop:disable Metrics/MethodLength
      def show
        # TODO: FIXME the following two lines are not needed when patient sync problem is solved
        #             can also enable the Metrics/MethodLength cop again, then
        @patient.execute_data_sync(current_user)

        @computations = @pipeline.computations.order(:created_at)
        @refresh = @computations.any?(&:active?)
        @proxy = Proxy.new(current_user) if current_user.proxy.present?

        if request.xhr?
          render partial: 'patients/pipelines/computations/show', layout: false,
                 locals: {
                   patient: @patient, pipeline: @pipeline, refresh: @refresh,
                   computation: @computation, computations: @computations, proxy: @proxy
                 }
        end
      end
      # rubocop:enable Metrics/MethodLength

      def update
        p = "/patients/#{params[:patient_id]}/pipelines/#{params[:pipeline_id]}"\
            "/computations/#{params[:id]}"
        @computation.revision = params[p][:revision]
        @computation.save
        run_computation
      end

      private

      def run_computation
        if @computation.runnable?
          @computation.run
          redirect_to patient_pipeline_computation_path(@patient, @pipeline, @computation),
                      notice: I18n.t('computations.update.started')
        else
          @computations = @pipeline.computations
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

      def lookup_repo
        @repo = Rails.application.config_for('eurvalve')['git_repos'][params[:id]]
      end
    end
  end
end
