# frozen_string_literal: true

class ProjectChannel < ApplicationCable::Channel
  def subscribed
    stream_for project
  end

  private

  def project
    Project.find_by(project_name: params[:project])
  end
end
