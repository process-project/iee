# frozen_string_literal: true

# rubocop:disable ClassLength
class Flow
  FLOWS = {
    inference_variants: %w[
      rule_selection inference_weighting patient_db_selection
      iteration_control results_presentation
    ],
    avr_surgical_preparation: %w[segmentation rom],
    avr_from_scan_rom: %w[
      segmentation rom parameter_optimization 0d_models
      uncertainty_analysis pressure_volume_display
    ],
    avr_from_scan_cfd: %w[
      segmentation cfd parameter_optimization
      0d_models uncertainty_analysis haemodynamic_comparison
    ],
    avr_tavi_cfd: %w[
      segmentation valve_sizing prosthetic_geometries valve_placement
      cfd parameter_optimization 0d_models uncertainty_analysis
      haemodynamic_comparison
    ],
    avr_valve_selection: %w[
      segmentation valve_sizing prosthetic_geometries valve_placement
      cfd parameter_optimization 0d_models uncertainty_analysis
      haemodynamic_comparison
    ],
    avr_intervention_timing: %w[
      segmentation rom parameter_optimization uncertainty_analysis
      progression_model results_comparison
    ],
    av_classification: %w[
      segmentation rom parameter_optimization uncertainty_analysis
      severity_model results_comparison
    ],
    avr_risk_benefit: %w[
      segmentation rom parameter_optimization uncertainty_analysis
      economics_algorithm results_comparison
    ],
    prosthetic_angle_tilt: %w[
      segmentation valve_sizing prosthetic_geometries valve_placement_x12
      cfd_x12 results_comparison
    ],
    avr_long_term_post_op: %w[
      segmentation rom parameter_optimization 0d_models uncertainty_analysis
      ageing_model_x2 cfd results_comparison
    ],
    mvr_from_scan_rom: %w[
      mv_segmentation rom parameter_optimization 0d_models
      uncertainty_analysis pv_loop_comparison
    ],
    cloud_test: %w[
      sample_cloud_step
      sample_cluster_step
    ],
    cloud_test_2: %w[
      rom
    ],
    unused_steps: %w[heart_model_calculation blood_flow_simulation]
  }.freeze

  STEPS = [
    ScriptedStep.new('ageing_model_x2', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new(
      'blood_flow_simulation',
      'eurvalve/blood-flow',
      'blood_flow.sh.erb',
      [:fluid_virtual_model, :ventricle_virtual_model]
    ),
    ScriptedStep.new('cfd', 'eurvalve/cfd', 'cfd.sh.erb', [:truncated_off_mesh]),
    ScriptedStep.new('cfd_x12', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new('economics_algorithm', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new('haemodynamic_comparison', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new(
      'heart_model_calculation',
      'eurvalve/0dmodel',
      'heart_model.sh.erb',
      [:estimated_parameters]
    ),
    ScriptedStep.new('inference', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new('inference_weighting', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new('iteration_control', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new('mv_segmentation', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new(
      'parameter_extraction',
      'eurvalve/parameter-extraction',
      'parameter_extraction.sh.erb',
      [:off_mesh]
    ),
    ScriptedStep.new(
      'parameter_optimization',
      'eurvalve/0dmodel',
      'parameter_optimization.sh.erb',
      [:pressure_drops]
    ),
    ScriptedStep.new('patient_db_selection', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new(
      'pressure_volume_display',
      'eurvalve/0dmodel',
      'pv_display.sh.erb',
      [:data_series_1, :data_series_2, :data_series_3, :data_series_4]
    ),
    ScriptedStep.new('progression_model', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new('prosthetic_geometries', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new('pv_loop_comparison', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new('results_comparison', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new('results_presentation', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new('rom', 'eurvalve/cfd', 'rom.sh.erb', [:response_surface]),
    ScriptedStep.new('rule_selection', 'eurvalve/mock-step', 'mock.sh.erb', []),
    WebdavStep.new('segmentation',
                   {
                     'Workflow 0 (CT Aortic Valve Segmentation)' => '0',
                     'Workflow 1 (US Philips Data Conversion)' => '1',
                     'Workflow 2 (TTE Left Ventricular Segmentation)' => '2',
                     'Workflow 3 (TEE Aortic Valve Segmentation)' => '3',
                     'Workflow 5 (Mitral Valve TEE Segmentation)' => '5',
                     'Workflow 7 (TEE Chamber Segmentation)' => '7',
                     'Workflow 8 (US Philips Data Conversion With Screenshots)' => '8',
                     'Workflow 9 (CT Data Conversion With Screenshots)' => '9'
                   },
                   [:image]),
    ScriptedStep.new('severity_model', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new(
      'uncertainty_analysis',
      'eurvalve/0dmodel',
      'uncertainty_analysis.sh.erb',
      [:parameter_optimization_result]
    ),
    ScriptedStep.new('valve_placement', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new('valve_placement_x12', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new('valve_sizing', 'eurvalve/mock-step', 'mock.sh.erb', []),
    ScriptedStep.new(
      '0d_models',
      'eurvalve/0dmodel',
      '0d_scenarios.sh.erb',
      [:parameter_optimization_result]
    ),
    ScriptedStep.new(
      'sample_cloud_step',
      'eurvalve/mock-step',
      'cloud_mock.sh.erb',
      [],
      deployments: %w[cluster cloud]
    ),
    ScriptedStep.new('sample_cluster_step', 'eurvalve/mock-step', 'mock.sh.erb', [])
  ].freeze

  steps_hsh = Hash[STEPS.map { |s| [s.name, s] }]
  FLOWS_MAP = Hash[FLOWS.map { |key, steps| [key, steps.map { |s| steps_hsh[s] }] }]

  def self.types
    FLOWS_MAP.keys
  end

  def self.steps(flow_type)
    FLOWS_MAP[flow_type.to_sym] || []
  end
end
# rubocop:enabled ClassLength
