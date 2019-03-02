# frozen_string_literal: true

FactoryBot.define do
  factory :container_registry do
    registry_url { 'shub://' }
  end
end
