# frozen_string_literal: true

FactoryBot.define do
  factory :ip do
    sequence(:address, (1..254).cycle) { |n| "149.156.10.#{n}" }

    trait :us do
      sequence(:address, (1..254).cycle) { |n| "8.8.8.#{n}" }
    end

    user
  end
end
