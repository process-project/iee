# frozen_string_literal: true

module Projects
  class PipelinesController < ApplicationController
    before_action :load_project
    before_action :find_and_authorize, only: [:show, :edit, :update, :destroy]

    def index
      redirect_to(project_path(@project))
    end

    def new
      ActivityLogWriter.write_message(current_user, nil, nil, 'pipeline_creation_request')
      @pipeline = Pipeline.new(owners)
      authorize(@pipeline)

      pipeline_steps_form if request.xhr?
    end

    def create
      @pipeline = create_pipeline
      ActivityLogWriter.write_message(current_user, @pipeline, nil, 'pipeline_created')
      if @pipeline.errors.empty?
        @project.execute_data_sync(current_user) # TODO: remove
        ::Pipelines::StartRunnable.new(@pipeline).call if @pipeline.automatic?
        redirect_to(project_pipeline_path(@project, @pipeline))
      else
        render(:new)
      end
    end

    def show
      @pipeline = @project.pipelines.find_by(iid: params[:id])
      computation = @pipeline.computations.first

      return unless computation
      redirect_to(project_pipeline_computation_path(@project,
                                                    @pipeline,
                                                    computation))
    end

    def edit; end

    def update
      if @pipeline.update_attributes(permitted_attributes(@pipeline))
        redirect_to(project_pipeline_path(@project, @pipeline))
      else
        render(:edit)
      end
    end

    def destroy
      if ::Pipelines::Destroy.new(@pipeline).call
        redirect_to project_path(@project),
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
        render partial: 'projects/pipelines/computations_form_automatic',
               locals: { steps_config: steps_config },
               layout: false
      else
        render partial: 'projects/pipelines/computations_form_manual',
               locals: { steps_config: steps_config },
               layout: false
      end
    end

    def steps_config
      ::Pipelines::StepsConfig.
        new(params[:flow], force_reload: params[:force_reload]).call
    end

    def owners
      { project: @project, user: current_user }
    end

    def load_project
      @project = Project.find_by!(project_name: params[:project_id])
    end

    def find_and_authorize
      @pipeline = @project.pipelines.find_by(iid: params[:id])
      authorize(@pipeline)
    end
  end
end
