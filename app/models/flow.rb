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
    unused_steps: %w[heart_model_calculation blood_flow_simulation]
  }.freeze

  STEPS = [
    RimrockStep.new('ageing_model_x2', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('blood_flow_simulation',
                    'eurvalve/blood-flow', 'blood_flow.sh.liquid',
                    [:fluid_virtual_model, :ventricle_virtual_model]),
    RimrockStep.new('cfd', 'eurvalve/cfd', 'cfd.sh.liquid', [:truncated_off_mesh]),
    RimrockStep.new('cfd_x12', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('economics_algorithm', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('haemodynamic_comparison', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('heart_model_calculation',
                    'eurvalve/0dmodel', 'heart_model.sh.liquid',
                    [:estimated_parameters]),
    RimrockStep.new('inference', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('inference_weighting', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('iteration_control', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('mv_segmentation', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('parameter_extraction',
                    'eurvalve/parameter-extraction', 'parameter_extraction.sh.liquid',
                    [:off_mesh]),
    RimrockStep.new('parameter_optimization',
                    'eurvalve/0dmodel', 'parameter_optimization.sh.liquid',
                    [:pressure_drops]),
    RimrockStep.new('patient_db_selection', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('pressure_volume_display',
                    'eurvalve/0dmodel', 'pv_display.sh.liquid',
                    [:data_series_1, :data_series_2,
                     :data_series_3, :data_series_4]),
    RimrockStep.new('progression_model', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('prosthetic_geometries', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('pv_loop_comparison', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('results_comparison', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('results_presentation', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('rom', 'eurvalve/cfd', 'rom.sh.liquid', [:response_surface]),
    RimrockStep.new('rule_selection', 'eurvalve/mock-step', 'mock.sh.liquid'),

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

    RimrockStep.new('severity_model', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('uncertainty_analysis',
                    'eurvalve/0dmodel', 'uncertainty_analysis.sh.liquid',
                    [:parameter_optimization_result]),
    RimrockStep.new('valve_placement', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('valve_placement_x12', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('valve_sizing', 'eurvalve/mock-step', 'mock.sh.liquid'),
    RimrockStep.new('0d_models',
                    'eurvalve/0dmodel', '0d_scenarios.sh.liquid',
                    [:parameter_optimization_result])
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
# rubocop:enable ClassLength
