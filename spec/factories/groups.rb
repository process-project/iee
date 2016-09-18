# frozen_string_literal: true
FactoryGirl.define do
  factory :group do
    name { Faker::Name.name }

    before(:create) do |group, _evaluator|
      unless group.user_groups.any?(&:owner)
        group.user_groups.build(user: create(:user), owner: true)
      end
    end

    factory :supervisor_group do
      name 'supervisor'
    end
  end
end
