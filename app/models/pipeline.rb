# frozen_string_literal: true

class Pipeline < ApplicationRecord
  FLOWS = {
    full_body_scan: [
      PipelineStep::Segmentation,
      PipelineStep::ParameterExtraction,
      PipelineStep::BloodFlowSimulation,
      PipelineStep::HeartModelCalculation
    ],
    full_body_scan_with_rom: [
      PipelineStep::Segmentation,
      PipelineStep::Rom,
      PipelineStep::ParameterOptimization,
      PipelineStep::ZeroDModels,
      PipelineStep::PressureVolumeDisplay,
      PipelineStep::UncertaintyAnalysis
    ],
    full_body_scan_with_cfd: [
      PipelineStep::Segmentation,
      PipelineStep::Cfd,
      PipelineStep::ParameterOptimization,
      PipelineStep::ZeroDModels,
      PipelineStep::PressureVolumeDisplay,
      PipelineStep::UncertaintyAnalysis
    ],
    partial_body_scan: [
      PipelineStep::Segmentation,
      PipelineStep::BloodFlowSimulation,
      PipelineStep::HeartModelCalculation
    ],
    something_else: [
      PipelineStep::Segmentation,
      PipelineStep::ParameterExtraction
    ]
  }.freeze

  enum mode: [:automatic, :manual]

  belongs_to :patient
  belongs_to :user
  has_many :data_files, dependent: :destroy
  has_many :computations, dependent: :destroy

  validate :set_iid, on: :create
  validates :iid, presence: true, numericality: true
  validates :name, presence: true
  validates :mode, presence: true

  scope :automatic, -> { where(mode: :automatic) }

  validates :flow,
            inclusion: { in: Pipeline::FLOWS.keys.map(&:to_s) }

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
    DataFile.find_by(patient: patient,
                     pipeline: [nil, self], data_type: data_type)
  end

  private

  def set_iid
    self.iid = patient.pipelines.maximum(:iid).to_i + 1 if iid.blank?
  end
end
