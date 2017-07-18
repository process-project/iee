# frozen_string_literal: true

namespace :resources do
  desc 'Generates resources without any assocations to other models'
  task generate: :environment do
    n = (ENV['N'] || 10).to_i
    raise 'N must be grater than 0' if n <= 0
    n.times do
      Resource.create(
        name: SecureRandom.urlsafe_base64(8),
        uri: SecureRandom.urlsafe_base64(8)
      )
    end
  end
end
