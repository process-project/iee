# frozen_string_literal: true

class ComputationUpdater
  attr_reader :computation, :computations, :pipeline, :patient

  def initialize(computation:, only_other: false)
    @computation = computation
    @computations = Computation.
                    where(pipeline_id: computation.pipeline_id).
                    order(:created_at)
    @pipeline = computation.pipeline
    @patient = pipeline.patient
    @only_other = only_other
  end

  def call
    computations.
      reject { |c| only_other? && c.id == computation.id }.
      each { |c| broadcast_to(c) }
  end

  private

  def broadcast_to(to)
    PipelineChannel.broadcast_to(to,
                                 menu: menu,
                                 reload_step: to.id == computation.id,
                                 reload_files: reload?)
  end

  def menu
    @menu ||= ApplicationController.
              render(partial: 'patients/pipelines/computations/menu',
                     locals: { patient: patient, pipeline: pipeline,
                               computation: computation,
                               computations: computations })
  end

  def reload?
    computation.status == 'finished'
  end

  def only_other?
    @only_other
  end
end
