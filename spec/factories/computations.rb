# frozen_string_literal: true

FactoryBot.define do
  factory :computation do
    pipeline_step 'rule_selection'
    script { Faker::Lorem.sentence }
    working_directory { Faker::Lorem.characters(10) }
    started_at { Time.current }

    user
    pipeline

    factory :webdav_computation, class: 'WebdavComputation' do
      pipeline_step 'segmentation'
      input_path { '/inputs' }
      output_path { '/outputs' }
      deployment 'service'
      script nil
    end

    factory :rimrock_computation, class: 'RimrockComputation' do
      pipeline_step '0d_models'
      input_path nil
      output_path nil
      script { 'SCRIPT' }
      tag_or_branch 'master'
      deployment 'cluster'
      revision '1234'
    end
  end
end
