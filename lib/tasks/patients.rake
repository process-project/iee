# frozen_string_literal: true

namespace :patients do
  desc 'Synchronizes all Prospective Study patients who have imaging modality assigned'
  task synchronize: :environment do
    sync_user_email = Rails.configuration.constants['data_sets']['sync_user_email']
    group_eurvalve_research = Group.find_by(name: 'Eurvalve_research')
    raise 'Unable to find "Eurvalve_research" group' unless group_eurvalve_research
    group_cyfronet = Group.find_by(name: 'Cyfronet')
    raise 'Unable to find "Cyfronet" group' unless group_cyfronet
    user = User.find_or_create_by(email: sync_user_email) do |new_user|
      passwd = SecureRandom.urlsafe_base64
      new_user.first_name = 'Lucky'
      new_user.last_name = 'Luke'
      new_user.password = passwd
      new_user.password_confirmation = passwd
      new_user.state = :approved
      new_user.groups = [group_eurvalve_research, group_cyfronet]
    end
    raise 'Unable to find or create update user' unless user.persisted?

    SynchronizePatientsJob.new.perform_now
  end
end
