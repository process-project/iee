namespace :compute_sites do
  desc 'Seed known compute sites'

  task seed: :environment do
    ComputeSite.create!(name: 'LRZ')
    ComputeSite.create!(name: 'Amsterdam')
  end
end