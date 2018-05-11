# frozen_string_literal: true

FactoryBot.define do
  factory :resource do
    sequence(:name) { |n| "resource_#{n}" }
    sequence(:path) { |n| "/resource/path/#{n}" }
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
