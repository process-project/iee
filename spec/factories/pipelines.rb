# frozen_string_literal: true

FactoryGirl.define do
  factory :pipeline do
    name { Faker::Name.unique.name }
    patient
    user
  end
end
