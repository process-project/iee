# frozen_string_literal: true

module Api
  class PipelinesController < Api::ApplicationController
    before_action :load_patient
    before_action :find_and_authorize, only: [:show, :destroy]

    def show
      render json: pipeline_json
    end

    def create
      @pipeline = create_pipeline

      if @pipeline.errors.empty?
        @patient.execute_data_sync(current_user)
        ::Pipelines::StartRunnable.new(@pipeline).call if @pipeline.automatic?
        render json: pipeline_json, status: :created
      else
        api_error status: 400, errors: @pipeline.errors
      end
    end

    def destroy
      if ::Pipelines::Destroy.new(@pipeline).call
        head :no_content
      else
        api_error error: I18n.t('pipelines.destroy.failure',
                                name: @pipeline.name)
      end
    end

    private

    def load_patient
      @patient = Patient.find_by!(case_number: params[:patient_id])
    end

    def pipeline_json
      PipelineSerializer.new(@pipeline, include: [:computations])
    end

    def find_and_authorize
      @pipeline = @patient.pipelines.includes(:computations).find_by(iid: params[:id])
      authorize(@pipeline)
    end

    def create_pipeline
      pipeline = Pipeline.new(permitted_attributes(Pipeline).merge(defaults))
      ::Pipelines::Create.new(pipeline, master_branch(pipeline)).call
    end

    def defaults
      { patient: @patient, user: current_user, mode: 'automatic' }
    end

    def master_branch(pipeline)
      Hash[pipeline.steps.map { |step| [step.name, { tag_or_branch: "master" }] }]
    end
  end
end
