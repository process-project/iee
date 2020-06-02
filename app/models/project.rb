# frozen_string_literal: true

class Project < ApplicationRecord
  has_many :pipelines,
           -> { order(iid: :asc) },
           dependent: :destroy

  validates :project_name, presence: true
  validates :project_name, uniqueness: true
  validates :project_name, format: { with: /\A[a-zA-Z0-9_\-.]+\z/ }

  default_scope { order('project_name asc') }

  def to_param
    project_name
  end

  def status
    pipelines.last&.status
  end
end
