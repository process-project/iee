# frozen_string_literal: true
FactoryGirl.define do
  factory :resource do
    name { Faker::Name.name }
    path { Faker::Internet.domain_word }
    resource_type :local
    service
  end
end
