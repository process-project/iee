# frozen_string_literal: true
FactoryGirl.define do
  factory :pipeline do
    name { Faker::Name.name }
    patient
    user
  end
end
