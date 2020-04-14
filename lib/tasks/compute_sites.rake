# frozen_string_literal: true

namespace :compute_sites do
  desc 'Seed known compute sites'

  task seed: :environment do
    ComputeSite.create!(name: 'LRZ')
    ComputeSite.create!(name: 'Amsterdam')
    ComputeSite.create!(name: 'Cyfronet')
  end
end