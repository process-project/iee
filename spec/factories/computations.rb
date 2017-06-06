# frozen_string_literal: true
FactoryGirl.define do
  factory :computation do
    pipeline_step { Pipeline::STEPS.first::STEP_NAME }
    script { Faker::Lorem.sentence }
    working_directory { Faker::Lorem.characters(10) }

    user
    pipeline

    factory :webdav_computation do
      type 'WebdavComputation'
      input_path { '/inputs' }
      output_path { '/outputs' }
    end

    factory :rimrock_computation do
      type 'RimrockComputation'
      script { 'SCRIPT' }
    end
  end
end
