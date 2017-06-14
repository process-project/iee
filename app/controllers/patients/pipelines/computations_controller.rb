# frozen_string_literal: true
module Patients
  module Pipelines
    class ComputationsController < ApplicationController
      before_action :find_and_authorize

      def show
        @computations = @pipeline.computations.order(:created_at)
        @refresh = @computations.any?(&:active?)
        @proxy = Proxy.new(current_user) unless current_user.proxy.blank?

        if request.xhr?
          render partial: 'patients/pipelines/computations/show', layout: false,
                 locals: {
                   patient: @patient, pipeline: @pipeline, refresh: @refresh,
                   computation: @computation, computations: @computations, proxy: @proxy
                 }
        end
      end

      def update
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

      private

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
    end
  end
end
