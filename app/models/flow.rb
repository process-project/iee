# frozen_string_literal: true

# rubocop:disable ClassLength
class Flow
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

  def self.types
    FLOWS.keys
  end

  def self.steps(flow_type)
    FLOWS[flow_type.to_sym] || []
  end
end
# rubocop:enabled ClassLength
