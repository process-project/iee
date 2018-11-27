# frozen_string_literal: true

FactoryBot.define do
  factory :data_file do
    sequence(:name) { |n| "data_file_#{n}" }
    data_type { 0 }
    patient
  end
end
