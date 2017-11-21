# frozen_string_literal: true

FactoryBot.define do
  factory :service_ownership do
    service
    user
  end
end
