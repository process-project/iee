# frozen_string_literal: true

class TriggerUpdateJob < ApplicationJob
  queue_as :computation

  def perform
    trigger_rimrock_jobs_update
    trigger_webdav_jobs_update
    trigger_singularity_jobs_update
  end

  private

  def trigger_rimrock_jobs_update
    User.all.each do |user|
      user.computations.created.each do |c|
        c.run if c.rimrock? and c.runnable?
        ComputationUpdater.new(c).call
      end
    end

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
    User.all.each do |user|
      user.computations.created.each do |c|
        c.run if c.singularity? and c.runnable?
        ComputationUpdater.new(c).call
      end
    end

    User.with_submitted_computations('SingularityComputation').each do |user|
      Rimrock::UpdateJob.perform_later(user)
    end
  end
end
