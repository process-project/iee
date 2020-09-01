# frozen_string_literal: true

class SingularityRegistry
  STEPS = {
    singularity_placeholder_step: %w[vsoch/hello-world],
    medical_step: %w[maragraziani/ucdemo],
    lofar_step: %w[factor-iee.sif uc2_factor_fast.sif],
    testing_singularity_step_1: %w[testing_container_1.sif],
    testing_singularity_step_2: %w[testing_container_2.sif]
  }.freeze

  CONTAINERS = {
    'vsoch/hello-world' => %w[latest],
    'maragraziani/ucdemo' => %w[0.1],
    'factor-iee.sif' => %w[latest],
    'uc2_factor_fast.sif' => %w[latest],
    'testing_container_1.sif' => %w[whatever_tag_and_it_is_to_remove],
    'testing_container_2.sif' => %w[whatever_tag_and_it_is_to_remove]
  }.freeze

  def self.fetch_containers(step_name)
    container_names = STEPS.fetch(step_name.to_sym)

    result_containers = {}

    CONTAINERS.each do |container, tags|
      result_containers[container] = tags if container_names.include? container
    end

    result_containers
  rescue KeyError
    Rails.logger.error("Containers and tags for step #{step_name} not found.")
    nil
  end
end
