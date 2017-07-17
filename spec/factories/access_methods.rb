# frozen_string_literal: true

FactoryGirl.define do
  factory :access_method do
    name { Faker::Lorem.unique.word }

    trait :service_scoped do
      service
    end
  end
end
