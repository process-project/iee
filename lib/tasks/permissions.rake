namespace :permissions do
  desc 'Generates permission randomly associated with resources,'\
    ' action, groups and users'
  task generate: :environment do
    n = (ENV['N'] || 10).to_i
    raise 'N must be grater than 0' if n <= 0
    users = User.all
    groups = Group.all
    resources = Resource.all
    actions = Action.all
    n.times do
      permission_attr = {
        action: actions.sample,
        resource: resources.sample
      }
      if Random.rand > 0.5
        permission_attr[:group] = groups.sample
      else
        permission_attr[:user] = users.sample
      end
      Permission.create permission_attr
    end
  end

end
