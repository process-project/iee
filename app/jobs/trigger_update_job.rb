# frozen_string_literal: true

class TriggerUpdateJob < ApplicationJob
  queue_as :computation

  def perform
    trigger_rimrock_jobs_update
    trigger_webdav_jobs_update
    trigger_singularity_jobs_update
    trigger_rest_jobs_update
    trigger_cloudify_jobs_update
    trigger_lobcder_jobs_update
  end

  private

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

  def trigger_singularity_jobs_update
    User.with_submitted_computations('SingularityComputation').each do |user|
      Rimrock::UpdateJob.perform_later(user)
    end
  end

  def trigger_rest_jobs_update
    User.with_created_or_submitted_computations('RestComputation').each do |user|
      Rest::UpdateJob.perform_later(user)
    end
  end

  def trigger_cloudify_jobs_update
    User.with_submitted_computations('CloudifyComputation').each do |user|
      Cloudify::UpdateJob.perform_later(user)
    end
  end

  def trigger_lobcder_jobs_update
    # User.with_submitted_computations('LobcderComputation').each do |user|
    #   Lobcder::UpdateJob.perform_later(user)
    # end

    Computation.where(type: 'LobcderComputation', status: %w[queued running]).each do |computation|
      Lobcder::UpdateJob.perform_later(computation)
    end
  end
end
