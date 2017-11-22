# frozen_string_literal: true

FactoryBot.define do
  factory :access_policy do
    access_method
    resource

    trait :user_access_policy do
      user
    end

    trait :group_access_policy do
      group
    end

    factory :user_access_policy, traits: [:user_access_policy]
    factory :group_access_policy, traits: [:group_access_policy]
  end
end
