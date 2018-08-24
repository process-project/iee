# frozen_string_literal: true

class Project < ApplicationRecord
  has_many :data_files, dependent: :destroy
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

  def execute_data_sync(user)
    WebdavDataFileSynchronizer.new(self, user).call
  end

  def working_dir
    File.join(Rails.env, 'projects', project_name, '/')
  end

  def working_url
    File.join(Webdav::FileStore.url, Webdav::FileStore.path, working_dir)
  end

  def inputs_dir(prefix = working_dir)
    File.join(prefix, 'inputs', '/')
  end

  def inputs_url
    inputs_dir(working_url)
  end

  def pipelines_dir(prefix = working_dir)
    File.join(prefix, 'pipelines', '/')
  end

  def pipelines_url
    pipelines_dir(working_url)
  end

  def status
    pipelines.last&.status
  end
end
