# frozen_string_literal: true
FactoryGirl.define do
  factory :resource do
    name { Faker::Name.name }
    path { Faker::Internet.domain_word }
    resource_type :local
    service

    trait :global do
      resource_type :global
    end

    factory :global_resource, traits: [:global]
  end
end
