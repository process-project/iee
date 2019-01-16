# frozen_string_literal: true

FactoryBot.define do
  factory :computation do
    sequence(:working_directory) { |n| "working_dir_#{n}" }
    started_at { Time.current }

    user
    pipeline

    factory :webdav_computation, class: 'WebdavComputation' do
      pipeline_step 'placeholder_step'
      input_path '/inputs'
      output_path '/outputs'
      run_mode 'Workflow 3 (TEE Aortic Valve Segmentation)'
    end

    factory :rimrock_computation, class: 'RimrockComputation' do
      pipeline_step 'placeholder_step'
      input_path nil
      output_path nil
      script 'SCRIPT'
      tag_or_branch 'master'
      revision '1234'
    end

    factory :singularity_computation, class: 'SingularityComputation' do
      pipeline_step 'singularity_placeholder_step'
      script 'SCRIPT'
      container_name 'lolcow'
      # container_registry_id nil
      container_tag 'latest'
    end
  end
end
