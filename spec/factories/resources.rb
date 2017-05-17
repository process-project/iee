# frozen_string_literal: true
FactoryGirl.define do
  factory :resource do
    name { Faker::Name.unique.name }
    path { '/' + Faker::Internet.unique.domain_word }
    resource_type :local
    service

    trait :global do
      resource_type :global
    end

    trait :local do
      resource_type :local
    end

    factory :global_resource, traits: [:global]
    factory :local_resource, traits: [:local]
  end
end
