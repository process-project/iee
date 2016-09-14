# frozen_string_literal: true
FactoryGirl.define do
  factory :group do
    name { Faker::Name.name }

    after(:create) do |group, _evaluator|
      unless UserGroup.where(group: group, owner: true).count.positive?
        group.user_groups.create(user: create(:user), owner: true)
      end
    end

    factory :supervisor_group do
      name 'supervisor'
    end
  end
end
