FactoryGirl.define do
  factory :permission do
    action
    resource

    trait :user_permission do
      user
    end

    trait :group_permission do
      group
    end

    factory :user_permission, traits: [:user_permission]
    factory :group_permission, traits: [:group_permission]
  end
end

