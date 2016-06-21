# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#creating an admin user with owned admin and supervisor groups
groups = ["admin", "supervisor"].map do |role_name|
  Group.find_or_create_by(name: role_name)
end
admin = User.find_by(email: "admin@host.domain")
admin ||= User.create(first_name: "admin", last_name: "admin", email: "admin@host.domain",
  password: "admin123", password_confirmation: "admin123", approved: true)
admin.groups = groups
admin.save
admin.user_groups.each do |user_group|
  user_group.owner = true
  user_group.save
end

# access methods
AccessMethod.find_or_create_by(name: 'manage')
AccessMethod.find_or_create_by(name: 'get')
AccessMethod.find_or_create_by(name: 'post')
AccessMethod.find_or_create_by(name: 'put')
AccessMethod.find_or_create_by(name: 'delete')
AccessMethod.find_or_create_by(name: 'propfind')
AccessMethod.find_or_create_by(name: 'options')
AccessMethod.find_or_create_by(name: 'mkcol')