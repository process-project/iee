# frozen_string_literal: true

FactoryBot.define do
  factory :patient do
    sequence(:case_number) { |n| "c#{n}" }

    trait :with_pipeline do
      case_number { '9900' }

      after(:build) do |patient|
        patient.pipelines << create(:pipeline)
      end
    end
  end
end
