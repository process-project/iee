# frozen_string_literal: true

FactoryBot.define do
  factory :pipeline do
    name { Faker::Name.unique.name }
    flow 'avr_from_scan_rom'
    patient
    user

    trait :with_computations do
      after(:build) do |pipeline|
        pipeline.steps.each { |step| step.builder_for(pipeline, {}).call }
      end
    end
  end
end
