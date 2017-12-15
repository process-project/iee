# frozen_string_literal: true

# rubocop:disable ClassLength
class Pipeline < ApplicationRecord
  FLOWS = {
    inference_variants: [
      PipelineStep::RuleSelection,
      PipelineStep::InferenceWeighting,
      PipelineStep::PatientDbSelection,
      PipelineStep::IterationControl,
      PipelineStep::ResultsPresentation
    ],
    avr_surgical_preparation: [
      PipelineStep::Segmentation,
      PipelineStep::Rom
    ],
    avr_from_scan_rom: [
      PipelineStep::Segmentation,
      PipelineStep::Rom,
      PipelineStep::ParameterOptimization,
      PipelineStep::ZeroDModels,
      PipelineStep::UncertaintyAnalysis,
      PipelineStep::PressureVolumeDisplay
    ],
    avr_from_scan_cfd: [
      PipelineStep::Segmentation,
      PipelineStep::Cfd,
      PipelineStep::ParameterOptimization,
      PipelineStep::ZeroDModels,
      PipelineStep::UncertaintyAnalysis,
      PipelineStep::HaemodynamicComparison
    ],
    avr_tavi_cfd: [
      PipelineStep::Segmentation,
      PipelineStep::ValveSizing,
      PipelineStep::ProstheticGeometries,
      PipelineStep::ValvePlacement,
      PipelineStep::Cfd,
      PipelineStep::ParameterOptimization,
      PipelineStep::ZeroDModels,
      PipelineStep::UncertaintyAnalysis,
      PipelineStep::HaemodynamicComparison
    ],
    avr_valve_selection: [
      PipelineStep::Segmentation,
      PipelineStep::ValveSizing,
      PipelineStep::ProstheticGeometries,
      PipelineStep::ValvePlacement,
      PipelineStep::Cfd,
      PipelineStep::ParameterOptimization,
      PipelineStep::ZeroDModels,
      PipelineStep::UncertaintyAnalysis,
      PipelineStep::HaemodynamicComparison
    ],
    avr_intervention_timing: [
      PipelineStep::Segmentation,
      PipelineStep::Rom,
      PipelineStep::ParameterOptimization,
      PipelineStep::UncertaintyAnalysis,
      PipelineStep::ProgressionModel,
      PipelineStep::ResultsComparison
    ],
    av_classification: [
      PipelineStep::Segmentation,
      PipelineStep::Rom,
      PipelineStep::ParameterOptimization,
      PipelineStep::UncertaintyAnalysis,
      PipelineStep::SeverityModel,
      PipelineStep::ResultsComparison
    ],
    avr_risk_benefit: [
      PipelineStep::Segmentation,
      PipelineStep::Rom,
      PipelineStep::ParameterOptimization,
      PipelineStep::UncertaintyAnalysis,
      PipelineStep::EconomicsAlgorithm,
      PipelineStep::ResultsComparison
    ],
    prosthetic_angle_tilt: [
      PipelineStep::Segmentation,
      PipelineStep::ValveSizing,
      PipelineStep::ProstheticGeometries,
      PipelineStep::ValvePlacementX12,
      PipelineStep::CfdX12,
      PipelineStep::ResultsComparison
    ],
    avr_long_term_post_op: [
      PipelineStep::Segmentation,
      PipelineStep::Rom,
      PipelineStep::ParameterOptimization,
      PipelineStep::ZeroDModels,
      PipelineStep::UncertaintyAnalysis,
      PipelineStep::AgeingModelX2,
      PipelineStep::Cfd,
      PipelineStep::ResultsComparison
    ],
    mvr_from_scan_rom: [
      PipelineStep::MvSegmentation,
      PipelineStep::Rom,
      PipelineStep::ParameterOptimization,
      PipelineStep::ZeroDModels,
      PipelineStep::UncertaintyAnalysis,
      PipelineStep::PvLoopComparison
    ],
    not_used_steps: [
      PipelineStep::HeartModelCalculation,
      PipelineStep::BloodFlowSimulation
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
  scope :latest, -> { order(created_at: :desc).limit(3) }

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
# rubocop:enabled ClassLength
