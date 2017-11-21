# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password '12345678'
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    trait :plgrid do
      plgrid_login { Faker::Name.unique.name }
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
    factory :plgrid_user, parent: :approved_user, traits: [:plgrid]
    factory :supervisor_user, parent: :approved_user, traits: [:supervisor]
    factory :admin, parent: :approved_user, traits: [:admin]
  end
end
