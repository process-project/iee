# frozen_string_literal: true
class Pipeline < ApplicationRecord
  belongs_to :patient
  belongs_to :user
  has_many :data_files

  validate :set_iid, on: :create
  validates :iid, presence: true, numericality: true
  validates :name, presence: true

  def to_param
    iid.to_s
  end

  def working_dir
    File.join(patient.pipelines_dir, iid.to_s, '/')
  end

  # NOTE: a temporary method to represent DataFiles stored for a given pipeline
  # Future version will remove this in favor of a has_many data_files relation
  # and synchronisation with WebDAV.
  include SynchronizerUtilities
  def data_files
    # dav_client = WebdavClient.new(
    #   webdav_storage_url,
    #   headers: {
    #     'Authorization' => "Bearer #{user.try(:token)}"
    #   }
    # )
    #
    # remote_names = []
    # @patient = patient
    # pipeline_directory = "#{case_directory(webdav_storage_url)}/pipelines/#{iid}"
    # dav_client.find(pipeline_directory, recursive: false) do |item|
    #   remote_names << item.properties.displayname
    # end
    #
    # remote_names.map do |remote_name|
    #   data_type = recognize_data_type(remote_name)
    #   next unless data_type
    #   {
    #     name: remote_name,
    #     data_type: data_type,
    #     content: dav_client.get_file_to_memory("#{pipeline_directory}/#{remote_name}")
    #   }
    # end
    []
  end

  # def get_file_to_memory(remote_path)
  #   io = StringIO.new
  #   @dav_client.get(remote_path) { |s| io.write(s) }
  #   io.close
  #   io.string
  # end

  private

  def set_iid
    self.iid = patient.pipelines.maximum(:iid).to_i + 1 if iid.blank?
  end
end
