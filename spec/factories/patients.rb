# frozen_string_literal: true
FactoryGirl.define do
  factory :patient do
    case_number { 'c' + Faker::Number.number(6).to_s }

    trait :with_pipeline do
      case_number '9900'

      after(:build) do |patient|
        patient.pipelines << create(:pipeline)
      end
    end
  end
end
