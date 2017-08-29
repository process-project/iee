# frozen_string_literal: true

class Pipeline < ApplicationRecord
  STEPS = [
    PipelineStep::Segmentation,
    PipelineStep::BloodFlowSimulation,
    PipelineStep::HeartModelCalculation
  ].freeze

  enum mode: [:automatic, :manual]

  belongs_to :patient
  belongs_to :user
  has_many :data_files
  has_many :computations, dependent: :destroy

  validate :set_iid, on: :create
  validates :iid, presence: true, numericality: true
  validates :name, presence: true
  validates :mode, presence: true

  def to_param
    iid.to_s
  end

  def working_dir(prefix = patient.pipelines_dir)
    File.join(prefix, iid.to_s, '/')
  end

  def working_url
    working_dir(patient.pipelines_url)
  end

  def data_file(data_type)
    patient.data_files.find_by(data_type: data_type)
  end

  private

  def set_iid
    self.iid = patient.pipelines.maximum(:iid).to_i + 1 if iid.blank?
  end
end
