# frozen_string_literal: true

class TriggerUpdateJob < ApplicationJob
  queue_as :computation

  def perform
    # trigger_runnable_jobs
    trigger_rimrock_jobs_update
    trigger_webdav_jobs_update
  end

  private

  def trigger_runnable_jobs
    Computation.unsubmitted.each do |computation|
      computation.pipeline.patient.execute_data_sync(computation.user)
      ComputationUpdater.new(computation).call
      Pipelines::StartRunnable.new(computation.pipeline).call
    end
  end

  def trigger_rimrock_jobs_update
    User.with_submitted_computations('RimrockComputation').each do |user|
      Rimrock::UpdateJob.perform_later(user)
    end
  end

  def trigger_webdav_jobs_update
    User.with_submitted_computations('WebdavComputation').each do |user|
      Webdav::UpdateJob.perform_later(user)
    end
  end
end
