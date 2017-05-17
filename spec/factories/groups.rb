# frozen_string_literal: true
FactoryGirl.define do
  factory :group do
    name { Faker::Name.unique.name }

    before(:create) do |group, _evaluator|
      unless group.user_groups.any?(&:owner)
        group.user_groups.build(user: create(:approved_user), owner: true)
      end
    end

    factory :supervisor_group do
      name 'supervisor'
    end

    factory :admin_group do
      name 'admin'
    end
  end
end
