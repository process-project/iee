# frozen_string_literal: true

FactoryBot.define do
  factory :pipeline do
    name { Faker::Name.unique.name }
    flow 'avr_from_scan_rom'
    patient
    user
  end
end
