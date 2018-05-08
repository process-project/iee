# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "johndoe#{n}@email.pl" }
    sequence(:first_name) { |n| "John#{n}" }
    sequence(:last_name) { |n| "Doe#{n}" }
    password '12345678'

    trait :plgrid do
      plgrid_login { |n| "plgjohndoe#{n}" }
    end

    trait :approved do
      state :approved
    end

    trait :supervisor do
      after(:create) do |user, _evaluator|
        group = build(:supervisor_group)
        group.user_groups.build(user: user, owner: true)
        group.save!
      end
    end

    trait :admin do
      after(:create) do |user, _|
        create(:admin_group).users << user
      end
    end

    trait :file_store_user do
      email { Rails.application.secrets[:test_file_store_email] }
    end

    factory :approved_user, traits: [:approved]
    factory :plgrid_user, traits: [:approved, :plgrid]
    factory :supervisor_user, traits: [:approved, :supervisor]
    factory :admin, traits: [:approved, :admin]
  end
end
