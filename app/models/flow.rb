# frozen_string_literal: true

# rubocop:disable ClassLength

class Flow
  FLOWS = {
    placeholder_pipeline: %w[placeholder_step],
    tensorflow_pipeline: %w[tf_cpu_step tf_gpu_step],
    singularity_test_gpu_pipeline: %w[singularity_test_gpu_step],
    singularity_placeholder_pipeline: %w[singularity_placeholder_step],
    medical_pipeline: %w[medical_step],
    lofar_pipeline: %w[lofar_step],
    # lufthansa_pipeline: %w[lufthansa_step],
    agrocopernicus_pipeline: %w[agrocopernicus_step],
    staging_in_placeholder_pipeline: %w[staging_in_step]

  }.freeze

  STEPS = [
    StagingInStep.new('staging_in_step',
                      [
                        StepParameter.new(
                          'src_host',
                          'Source Host',
                          'Descriptions placeholder',
                          0,
                          'multi',
                          'data03.process-project.eu',
                          ['data03.process-project.eu']
                        ),
                        StepParameter.new(
                          'src_path',
                          'Source Path',
                          'Descriptions placeholder',
                          1,
                          'multi',
                          '/mnt/dss/process/UC1/Camelyon16/TestData/Test_001.tif',
                          %w[/mnt/dss/process/UC1/Camelyon16/TestData/Test_001.tif]
                        ),
                        StepParameter.new(
                          'dest_host',
                          'Destination Host',
                          'Descriptions placeholder',
                          2,
                          'multi',
                          'pro.cyfronet.pl',
                          %w[pro.cyfronet.pl]
                        ),
                        StepParameter.new(
                          'dest_path',
                          'Destination Path',
                          'Descriptions placeholder',
                          3,
                          'multi',
                          '/net/archive/groups/plggprocess/Mock/test_staging',
                          %w[/net/archive/groups/plggprocess/Mock/test_staging]
                        )
                      ]
                      ),
    RimrockStep.new('placeholder_step',
                    'process-eu/mock-step',
                    'mock.sh.erb', [], []),
    RimrockStep.new('tf_cpu_step',
                    'process-eu/tensorflow-pipeline',
                    'tensorflow_cpu_mock_job.sh.erb', [], []),
    RimrockStep.new('tf_gpu_step',
                    'process-eu/tensorflow-pipeline',
                    'tensorflow_gpu_mock_job.sh.erb', [], []),
    RimrockStep.new('singularity_test_gpu_step',
                    'process-eu/singularity-pipeline',
                    'singularity_mock_job.sh.erb',
                    [:generic_type], []),
    SingularityStep.new('singularity_placeholder_step'),
    SingularityStep.new('medical_step'),
    SingularityStep.new('lofar_step'),
    SingularityStep.new('agrocopernicus_step',
                        ['input.csv'])
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
