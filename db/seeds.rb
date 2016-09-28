# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# creating an admin user with owned admin and supervisor groups
admin = User.find_by(email: 'admin@host.domain')
admin ||= User.create(first_name: 'admin', last_name: 'admin', email: 'admin@host.domain',
                      password: 'admin123', password_confirmation: 'admin123', approved: true)

%w(admin supervisor).map do |role_name|
  group = Group.find_or_initialize_by(name: role_name)
  group.user_groups.build(user: admin, owner: true)
  group.save!
end

# Global access methods
AccessMethod.find_or_create_by(name: 'manage')
