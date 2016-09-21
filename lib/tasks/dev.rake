if Rails.env.development? || Rails.env.test?
  require 'factory_girl'

  namespace :dev do
    desc 'Sample data for local development environment'
    task prime: 'db:setup' do
      include FactoryGirl::Syntax::Methods
      create(:approved_user, email: 'first@cyf.pl', password: 'FirstPassword')
      create(:approved_user, email: 'second@cyf.pl', password: 'SecondPassword')
      create(:approved_user, email: 'third@cyf.pl', password: 'ThirdPassword')

      create(:plgrid_user, email: 'plgfirst@cyf.pl', password: 'PlgFirstPassword')
      create(:plgrid_user, email: 'plgsecond@cyf.pl', password: 'PlgSecondPassword')
      create(:plgrid_user, email: 'plgthird@cyf.pl', password: 'PlgThirdPassword')

      create(:user, email: 'pendingfirst@cyf.pl', password: 'PendingFirstPassword')
      create(:user, email: 'pendingsecond@cyf.pl', password: 'PendingSecondPassword')
      create(:user, email: 'pendingthird@cyf.pl', password: 'PendingThirdPassword')

      users = User.approved
      users.to_a.each_index do |idx|
        group = build(:group)
        group.user_groups.build(user: users[idx], owner: true)
        group.user_groups.build(user: users[(idx + 1) % users.size])
        if idx % 3 == 2
          parent = Group.all[idx - 1]
          group.parents << parent
        end
        group.save!

        srv = create(:service, users: [users[idx]])
        access_method = create(:access_method, service: srv)
        res = create(:resource, service: srv)
        policy = build(:access_policy, resource: res, access_method: access_method)
        if idx.even?
          policy.user = users[idx]
        else
          policy.group = group
        end
        policy.save!
      end
      %w(finished error new queued running).each_with_index do |status, idx|
        create(:computation, user: users[idx], status: status)
      end
    end
  end
end
