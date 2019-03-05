# frozen_string_literal: true

class Flow
  FLOWS = {
    placeholder_pipeline: %w[placeholder_step],
    tensorflow_pipeline: %w[tf_cpu_step tf_gpu_step],
    singularity_test_gpu_pipeline: %w[singularity_test_gpu_step],
    singularity_placeholder_pipeline: %w[singularity_placeholder_step],
    medical_pipeline: %w[medical_step],
    lofar_pipeline: %w[lofar_step],
    lufthansa_pipeline: %w[lufthansa_step]

  }.freeze

  STEPS = [
    RimrockStep.new('placeholder_step',
                    'process-eu/mock-step',
                    'mock.sh.erb'),
    RimrockStep.new('tf_cpu_step',
                    'process-eu/tensorflow-pipeline',
                    'tensorflow_cpu_mock_job.sh.erb'),
    RimrockStep.new('tf_gpu_step',
                    'process-eu/tensorflow-pipeline',
                    'tensorflow_gpu_mock_job.sh.erb'),
    RimrockStep.new('singularity_test_gpu_step',
                    'process-eu/singularity-pipeline',
                    'singularity_mock_job.sh.erb',
                    [:generic_type]),
    SingularityStep.new('singularity_placeholder_step',
                        'shub://',
                        'vsoch/hello-world',
                        'latest'),
    SingularityStep.new('medical_step',
                        'shub://',
                        'maragraziani/ucdemo',
                        '0.1'),
    SingularityStep.new('lofar_step',
                        'shub://',
                        'vsoch/hello-world',
                        'latest'),
    SingularityStep.new('lufthansa_step',
                        'shub://',
                        'vsoch/hello-world',
                        'latest', ['input.csv'])
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
