# frozen_string_literal: true

class Flow
  FLOWS = {
    placeholder_pipeline: %w[placeholder_step]
  }.freeze

  STEPS = [
    RimrockStep.new('placeholder_step', 'patrykwojtowicz/mock-step', 'mock.sh.erb')
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
