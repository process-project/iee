# frozen_string_literal: true

class Flow
  FLOWS = {
    placeholder_pipeline: %w[placeholder_step],
    tensorflow_pipeline: %W[ts_computation]
  }.freeze

  STEPS = [
    RimrockStep.new('placeholder_step', 'process-eu/mock-step', 'mock.sh.erb')
    RimrockStep.new('ts_computation', 'patrykwojtowicz/tensorflow-pipeline', 'tensorflow_step.sh.erb')
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
