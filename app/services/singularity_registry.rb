# frozen_string_literal: true

class SingularityRegistry
  STEPS = {
    singularity_placeholder_step: %w[vsoch/hello-world],
    medical_step: %w[maragraziani/ucdemo],
    lofar_step: %w[lofar/lofar_container],
    agrocopernicus_step: %w[agrocopernicus_placeholder_container]
  }

  CONTAINERS = {
    'vsoch/hello-world' => %w[latest],
    'maragraziani/ucdemo' => %w[0.1],
    'lofar/lofar_container' => %w[latest],
    'agrocopernicus_placeholder_container' => %w[agrocopernicus_placeholder_tag]
  }

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

  def self.add_step(step_name, containers)
    STEPS[step_name.to_sym] = containers
  end

  def self.add_container(container_name, tags)
    CONTAINERS[container_name.to_sym] = tags
  end
end
