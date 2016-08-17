# frozen_string_literal: true
FactoryGirl.define do
  factory :service_ownership do
    service
    user
  end
end
