# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :set_projects, only: [:index]
  before_action :find_and_authorize, only: [:show, :destroy]

  def index
    if request.xhr?
      @stats = Projects::Statistics.new(@projects, current_user).call
      render json: @stats, layout: false
    end
  end

  def show
    @pipelines = @project.pipelines.includes(:computations, :project, :user).
                 order('computations.created_at')

    if request.xhr?
      @details = Projects::Details.new(@project.case_number, current_user).call
      render partial: 'projects/details', layout: false,
             locals: { project: @project, details: @details }
    end
  end

  def new
    @project = Project.new
    authorize(@project)
  end

  def create
    new_project = Project.new(permitted_attributes(Project))
    authorize(new_project)

    @project = Projects::Create.new(current_user, new_project).call

    if @project.errors.empty?
      @project.execute_data_sync(current_user)
      redirect_to @project, notice: I18n.t('projects.create.success')
    else
      render :new
    end
  end

  def destroy
    if Projects::Destroy.new(current_user, @project).call
      redirect_to projects_path,
                  notice: I18n.t('projects.destroy.success',
                                 case_number: @project.case_number)
    else
      render :show,
             notice: I18n.t('projects.destroy.failure',
                            case_number: @project.case_number)
    end
  end

  private

  def set_projects
    @projects = policy_scope(Project).includes(pipelines: :computations).all
  end

  def find_and_authorize
    @project = policy_scope(Project).find_by!(case_number: params[:id])
    authorize(@project)
  end
end
