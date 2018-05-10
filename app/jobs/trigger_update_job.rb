# frozen_string_literal: true

class TriggerUpdateJob < ApplicationJob
  queue_as :computation

  def perform
    trigger_rimrock_jobs_update
    trigger_webdav_jobs_update
    trigger_cloud_jobs_update
  end

  private

  def trigger_rimrock_jobs_update
    User.with_submitted_computations('cluster').each do |user|
      Rimrock::UpdateJob.perform_later(user)
    end
  end

  def trigger_webdav_jobs_update
    User.with_submitted_computations('service').each do |user|
      Webdav::UpdateJob.perform_later(user)
    end
  end

  def trigger_cloud_jobs_update
    User.with_submitted_computations('cloud').each do |user|
      Cloud::UpdateJob.perform_later(user)
    end
  end
end
