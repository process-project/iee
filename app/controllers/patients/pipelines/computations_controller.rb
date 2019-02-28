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
                   patient: @patient, pipeline: @pipeline,
                   computation: @computation, computations: @computations
                 }
        end
      end

      def update
        @computation.assign_attributes(permitted_attributes(@computation))
        if run_computation
          redirect_to patient_pipeline_computation_path(@patient, @pipeline, @computation),
                      notice: I18n.t("computations.update.started_#{@computation.mode}")
        else
          @computation.status = @computation.status_was
          prepare_to_show_computation
          render :show, status: :bad_request,
                        notice: I18n.t('computations.update.not_runnable')
        end
      end

      private

      def run_computation
        if @computation.manual?
          @computation.run
        else
          @computation.save.tap do |success|
            ::Pipelines::StartRunnable.new(@pipeline).call if success
          end
        end
      end

      def find_and_authorize
        @computation = Computation.
                       joins(pipeline: :patient).
                       find_by(patients: { case_number: params[:patient_id] },
                               pipelines: { iid: params[:pipeline_id] },
                               pipeline_step: params[:id])
        @pipeline = @computation.pipeline
        @patient = @pipeline.patient

        authorize(@computation)
      end

      def prepare_to_show_computation
        @computations = @pipeline.computations.flow_ordered
        if updatable?
          config = step.config(params[:force_reload])
          @versions = config[:tags_and_branches]
          @run_modes = config[:run_modes]
          @deployments = config[:deployments]
        end
      end

      def step
        @computation.step
      end

      def repo
        @repo ||= step.try(:repository)
      end

      def load_versions?
        repo && updatable?
      end

      def updatable?
        policy(@computation).update?
      end
    end
  end
end
