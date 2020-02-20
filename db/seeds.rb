# frozen_string_literal: true

case Rails.env
when 'developement'
  # require 'seeds_developement'
  admin = User.find_by(email: 'admin@host.domain')
  admin ||= User.create(first_name: 'admin', last_name: 'admin', email: 'admin@host.domain',
                        password: 'admin123', password_confirmation: 'admin123', state: :approved)

  %w[admin supervisor].map do |role_name|
    group = Group.find_or_initialize_by(name: role_name)
    group.user_groups.build(user: admin, owner: true)
    group.save!
  end
end
