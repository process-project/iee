# frozen_string_literal: true
module Patients
  module Pipelines
    class ComputationsController < ApplicationController
      before_action :find_and_authorize

      def show
        @computations = @pipeline.computations
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
    end
  end
end
