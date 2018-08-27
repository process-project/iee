# frozen_string_literal: true

class ComputationUpdater
  attr_reader :computation, :computations, :pipeline, :project

  def initialize(computation)
    @computation = computation
    @computations = Computation.
                    includes(:pipeline).
                    where(pipeline_id: computation.pipeline_id).
                    order(:created_at)
    @pipeline = computation.pipeline
    @project = pipeline.project
  end

  def call
    computations.each { |c| broadcast_to_computation(c) }
    broadcast_to_project(project)
  end

  private

  def broadcast_to_computation(to)
    ComputationChannel.broadcast_to(to,
                                    menu: menu(to),
                                    reload_step: to.id == computation.id,
                                    reload_files: reload?)
  end

  def menu(to)
    ApplicationController.
      render(partial: 'projects/pipelines/computations/menu',
             locals: { project: project, pipeline: pipeline,
                       computation: to, computations: computations })
  end

  def broadcast_to_project(to)
    ProjectChannel.broadcast_to(to, list: list(to))
  end

  def list(project)
    ApplicationController.
      render(partial: 'projects/pipelines/list',
             locals: { project: project, pipelines: pipelines })
  end

  def pipelines
    project.pipelines.includes(:computations).
      order(:iid).order('computations.created_at')
  end

  def reload?
    computation.status == 'finished'
  end
end
