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
      container_registry nil
      container_tag 'latest'
    end

    factory :staging_in_computation, class: 'StagingInComputation' do
      pipeline_step 'staging_in_step'
      src_host 'data03.process-project.eu'
      src_path '/mnt/dss/process/UC1/Camelyon16/TestData/Test_001.tif'
      dest_host 'pro.cyfronet.pl'
      dest_path '/net/archive/groups/plggprocess/UC1/test_staging_2'
    end
  end
end
