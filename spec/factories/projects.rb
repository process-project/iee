# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    sequence(:project_name) { |n| "c#{n}" }

    trait :with_pipeline do
      project_name '9900'

      after(:build) do |patient|
        project.pipelines << create(:pipeline)
      end
    end
  end
end
