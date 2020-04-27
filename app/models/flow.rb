# frozen_string_literal: true

# rubocop:disable ClassLength
class Flow
  FLOWS = {
    placeholder_pipeline: %w[placeholder_step],
    cloudify_placeholder_pipeline: %w[cloudify_step],
    singularity_placeholder_pipeline: %w[singularity_placeholder_step],
    medical_pipeline: %w[medical_step],
    lofar_pipeline: %w[lofar_step],
    agrocopernicus_pipeline: %w[agrocopernicus_step],
    staging_in_placeholder_pipeline: %w[staging_in_step],
    validation_pipeline: %w[validation_staging_in_step
                            validation_singularity_step
                            validation_stage_out_step],
    test_flow: %w[validation_staging_in_step
                  validation_singularity_step
                  validation_stage_out_step],
    test_pipeline: %w[directory_builder_step
                      staging_in_step
                      testing_singularity_step
                      staging_out_step]
  }.freeze

  USECASE_FLOWS = {
    medical_pipeline: :uc1,
    lofar_pipeline: :uc2,
    agrocopernicus_pipeline: :uc5,
    test_flow: :uc2
  }.freeze

  STEPS = [
    DirectoryBuilderStep.new('directory_builder_step'),
    SingularityStep.new('testing_singularity_step'),
    StagingInStep.new('staging_in_step'),
    ImplicitStagingStep.new('implicit_staging_step'),
    StagingOutStep.new('staging_out_step'),
    # Only above is important
    SingularityStep.new('validation_singularity_step',
                        ['staging_done.txt']),
    RimrockStep.new('validation_stage_out_step',
                    'process-eu/validation_stage_out',
                    'validation_stage_out_script.sh.erb', [:validation_type], []),
    RimrockStep.new('placeholder_step',
                    'process-eu/mock-step',
                    'mock.sh.erb', [], []),
    SingularityStep.new('singularity_placeholder_step'),
    SingularityStep.new('medical_step'),
    SingularityStep.new('lofar_step'),
    RestStep.new(
      'agrocopernicus_step',
      [
        StepParameter.new(
          label: 'irrigation',
          name: 'Irrigation',
          description: '',
          rank: 0,
          datatype: 'boolean',
          default: 'true'
        ),
        StepParameter.new(
          label: 'seeding_date',
          name: 'Seeding date',
          description: '',
          rank: 0,
          datatype: 'multi',
          default: '-15 days',
          values: ['-15 days', 'original', '+15 days']
        ),
        StepParameter.new(
          label: 'nutrition_factor',
          name: 'Nutrition factor',
          description: '',
          rank: 0,
          datatype: 'multi',
          default: '0.25',
          values: ['0.25', '0.45', '0.60']
        ),
        StepParameter.new(
          label: 'phenology_factor',
          name: 'Phenology factor',
          description: '',
          rank: 0,
          datatype: 'multi',
          default: '0.6',
          values: ['0.6', '0.8', '1.0', '1.2']
        )
      ]
    ),
    CloudifyStep.new('cloudify_step', [])
  ].freeze

  steps_hsh = Hash[STEPS.map { |s| [s.name, s] }]
  FLOWS_MAP = Hash[FLOWS.map { |key, steps| [key, steps.map { |s| steps_hsh[s] }] }]

  def self.types
    FLOWS_MAP.keys
  end

  def self.steps(flow_type)
    FLOWS_MAP[flow_type.to_sym] || []
  end

  def self.get_step(step_name)
    STEPS.find { |step| step.name == step_name }
  end

  def self.step_to_hash(step)
    Hash[step.parameters.map do |parameter|
      [parameter.name.to_sym, parameter.as_json.symbolize_keys.slice(:label,
                                                                     :name,
                                                                     :description,
                                                                     :rank,
                                                                     :datatype,
                                                                     :default,
                                                                     :values)]
    end]
  end

  def self.pipeline_to_hash(pipeline)
    Hash[FLOWS[pipeline.to_sym].map do |step_name|
           [step_name, step_to_hash(get_step(step_name))]
         end]
  end

  def self.flows_for(usecase)
    pipelines = USECASE_FLOWS.select { |_, uc| uc == usecase }.keys
    Hash[pipelines.map do |pipeline|
           [pipeline, pipeline_to_hash(pipeline)]
         end].deep_stringify_keys
  end

  def self.uc_for(flow)
    USECASE_FLOWS[flow]
  end
end
# rubocop:enable ClassLength
