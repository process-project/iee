# frozen_string_literal: true
FactoryGirl.define do
  factory :computation do
    pipeline_step { Patient::PIPELINE.keys.first.to_s }
    script { Faker::Lorem.sentence }
    working_directory { Faker::Lorem.characters(10) }

    user
    patient
  end
end
