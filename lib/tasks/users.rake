# frozen_string_literal: true
namespace :users do
  desc 'Generates users in DB for testing hierarchical groups performance'
  task generate: :environment do
    n = (ENV['N'] || 10).to_i
    raise 'N must be grater than 0' if n <= 0
    groups_per_user = (ENV['GROUPS_PER_USER'] || 5).to_i
    raise 'GROUPS_PER_USER must be grater than 0' if groups_per_user <= 0
    groups = Group.all
    n.times do
      first_name = SecureRandom.urlsafe_base64(8)
      passwd = SecureRandom.urlsafe_base64(8)
      u = User.new(
        first_name: first_name,
        last_name: SecureRandom.urlsafe_base64(8),
        email: "#{first_name}@host.domain",
        password: passwd,
        password_confirmation: passwd,
        approved: true
      )
      u.groups = groups.sample(groups_per_user)
      u.save!
    end
  end
end
