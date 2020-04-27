# frozen_string_literal: true

namespace :compute_sites do
  desc 'Seed known compute sites'

  task seed: :environment do
    Lobcder::Service.new(:uc1).folders.each do |name, values|
      # TODO: do something with placeholder_full_name
      ComputeSite.create!(name: name, full_name: 'placeholder_full_name', host: values[:host])
    end
  end
end
