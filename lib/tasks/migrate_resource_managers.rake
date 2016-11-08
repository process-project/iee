# frozen_string_literal: true
namespace :migration do
  task managers: :environment do
    manager_aps = AccessPolicy.joins(:access_method).
                  where(access_methods: { name: 'manage' })

    manager_aps.includes(:user, :group, :resource).find_each do |ap|
      ap.resource.resource_managers.
        find_or_create_by(user: ap.user, group: ap.group) if ap.resource
    end

    manager_aps.destroy_all
    AccessMethod.find_by(name: 'manage').destroy
  end
end
