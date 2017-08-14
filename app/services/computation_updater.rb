# frozen_string_literal: true

class ComputationUpdater
  attr_reader :computation, :computations, :pipeline, :patient

  def initialize(computation)
    @computation = computation
    @computations = Computation.
                    where(pipeline_id: computation.pipeline_id).
                    order(:created_at)
    @pipeline = computation.pipeline
    @patient = pipeline.patient
  end

  def call
    computations.each { |c| broadcast_to(c) }
  end

  private

  def broadcast_to(to)
    PipelineChannel.broadcast_to(to,
                                 menu: menu(to),
                                 reload_step: to.id == computation.id,
                                 reload_files: reload?)
  end

  def menu(to)
    ApplicationController.
      render(partial: 'patients/pipelines/computations/menu',
             locals: { patient: patient, pipeline: pipeline,
                       computation: to, computations: computations })
  end

  def reload?
    computation.status == 'finished'
  end
end
