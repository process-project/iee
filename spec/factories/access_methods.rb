# frozen_string_literal: true
FactoryGirl.define do
  factory :access_method do
    name { Faker::Name.name }
  end
end
