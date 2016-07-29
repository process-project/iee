# frozen_string_literal: true
FactoryGirl.define do
  factory :computation do
    script { Faker::Lorem.sentence }
    working_directory { Faker::Lorem.characters(10) }

    user
  end
end
