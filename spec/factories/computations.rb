# frozen_string_literal: true

FactoryGirl.define do
  factory :computation do
    pipeline_step { Pipeline::FLOWS.values.first.first::STEP_NAME }
    script { Faker::Lorem.sentence }
    working_directory { Faker::Lorem.characters(10) }
    started_at { Time.current }

    user
    pipeline

    factory :webdav_computation, class: 'WebdavComputation' do
      input_path { '/inputs' }
      output_path { '/outputs' }
      script nil
    end

    factory :rimrock_computation, class: 'RimrockComputation' do
      input_path nil
      output_path nil
      script { 'SCRIPT' }
      tag_or_branch 'master'
      revision '1234'
    end
  end
end
