# frozen_string_literal: true
module Patients
  class PipelinesController < ApplicationController
    before_action :load_patient
    before_action :find_and_authorize, only: [:show, :edit, :update, :destroy]

    def index
      redirect_to(patient_path(@patient))
    end

    def new
      @pipeline = Pipeline.new(owners)
      authorize(@pipeline)
    end

    def create
      @pipeline = Pipeline.new(permitted_attributes(Pipeline).merge(owners))

      if @pipeline.save
        redirect_to(patient_pipeline_path(@patient, @pipeline))
      else
        render(:new)
      end
    end

    def show
      @pipeline = @patient.pipelines.find_by(iid: params[:id])
    end

    def edit; end

    def update
      if @pipeline.update_attributes(permitted_attributes(@pipeline))
        redirect_to(patient_pipeline_path(@patient, @pipeline))
      else
        render(:edit)
      end
    end

    def destroy
      @pipeline.destroy
      redirect_to(patient_path(@patient))
    end

    private

    def owners
      { patient: @patient, user: current_user }
    end

    def load_patient
      @patient = Patient.find(params[:patient_id])
    end

    def find_and_authorize
      @pipeline = @patient.pipelines.find_by(iid: params[:id])
      authorize(@pipeline)
    end
  end
end
