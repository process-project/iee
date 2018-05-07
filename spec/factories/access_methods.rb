# frozen_string_literal: true

FactoryBot.define do
  factory :access_method do
    sequence(:name) { |n| "access_method_#{n}" }

    trait :service_scoped do
      service
    end
  end
end
