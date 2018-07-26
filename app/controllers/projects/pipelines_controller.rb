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

      pipeline_steps_form if request.xhr?
    end

    def create
      @pipeline = create_pipeline

      if @pipeline.errors.empty?
        @patient.execute_data_sync(current_user)
        ::Pipelines::StartRunnable.new(@pipeline).call if @pipeline.automatic?
        redirect_to(patient_pipeline_path(@patient, @pipeline))
      else
        render(:new)
      end
    end

    def show
      @pipeline = @patient.pipelines.find_by(iid: params[:id])
      computation = @pipeline.computations.first

      return unless computation
      redirect_to(patient_pipeline_computation_path(@patient,
                                                    @pipeline,
                                                    computation))
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
      if ::Pipelines::Destroy.new(@pipeline).call
        redirect_to patient_path(@patient),
                    notice: I18n.t('pipelines.destroy.success',
                                   name: @pipeline.name)
      else
        render :show,
               notice: I18n.t('pipelines.destroy.failure',
                              name: @pipeline.name)
      end
    end

    private

    def create_pipeline
      pipeline = Pipeline.new(permitted_attributes(Pipeline).merge(owners))
      ::Pipelines::Create.new(pipeline, params.require(:pipeline)).call
    end

    def pipeline_steps_form
      if params[:mode] == 'automatic'
        render partial: 'patients/pipelines/computations_form_automatic',
               locals: { steps_config: steps_config },
               layout: false
      else
        render partial: 'patients/pipelines/computations_form_manual',
               locals: { steps_config: steps_config },
               layout: false
      end
    end

    def steps_config
      ::Pipelines::StepsConfig.
        new(params[:flow], force_reload: params[:force_reload]).call
    end

    def owners
      { patient: @patient, user: current_user }
    end

    def load_patient
      @patient = Patient.find_by!(case_number: params[:patient_id])
    end

    def find_and_authorize
      @pipeline = @patient.pipelines.find_by(iid: params[:id])
      authorize(@pipeline)
    end
  end
end
