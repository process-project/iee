# frozen_string_literal: true

require 'rails_helper'

describe Audits::Perform do
  let(:user) { create(:user) }

  subject { described_class.new(user) }

  it 'do not notify when ip is the same' do
    ip1 = create(:ip, user: user)

    create(:ip,
           user: user,
           address: ip1.address)

    expect { subject.call }.
     to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'do not notify when user agent is the same' do
    a1 = create(:user_agent, user: user)

    create(:user_agent,
           user: user,
           name: a1.name,
           accept_language: a1.accept_language)

    expect { subject.call }.
        to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'notify when only browser vendor changes' do
    a1 = create(:user_agent,
                user: user,
                name: Faker::Internet.user_agent(:chrome))

    create(:user_agent,
           user: user,
           name: Faker::Internet.user_agent(:firefox),
           accept_language: a1.accept_language)

    expect { subject.call }.
     to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'do not notify when only browser version changes' do
    a1 = create(:user_agent,
                user: user,
                name: Faker::Internet.user_agent(:chrome))

    create(:user_agent,
           user: user,
           name: Faker::Internet.user_agent(:chrome),
           accept_language: a1.accept_language)

    expect { subject.call }.
        to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'do not notify when only ip changes' do
    create(:ip, user: user)

    create(:ip,
           user: user,
           address: Faker::Internet.public_ip_v4_address)

    expect { subject.call }.
        to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'do not notify when only ip\'s country changes' do
    # Cyfronet (PL)
    create(:ip,
           user: user,
           address: '149.156.11.38')

    # Google (US)
    create(:ip,
           user: user,
           address: '8.8.8.8')

    expect { subject.call }.
        to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'notify when ip\'s country and minor browser version changes' do
    b_v1 = 'Mozilla/5.0 (Windows NT 6.1)'\
           ' AppleWebKit/537.36 (KHTML, like Gecko)'\
           ' Chrome/41.0.2228.0 Safari/537.36'

    b_v2 = 'Mozilla/5.0 (Windows NT 6.1)'\
           ' AppleWebKit/537.36 (KHTML, like Gecko)'\
           ' Chrome/41.0.2229.0 Safari/537.36'

    # Cyfronet (PL)
    create(:ip,
          user: user,
          ip: '149.156.11.38')

    a1 = create(:user_agent,
                user: user,
                name: b_v1)

    # Google (US)
    create(:ip,
           user: user,
           ip: '8.8.8.8')

    create(:user_agent,
           user: user,
           name: b_v2,
           accept_language: a1.accept_language)

    expect { subject.call }.
        to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'notify when browser major version and lang changes' do
    b_v1 = 'Mozilla/5.0 (Windows NT 6.1)'\
           ' AppleWebKit/537.36 (KHTML, like Gecko)'\
           ' Chrome/41.0.2228.0 Safari/537.36'

    b_v2 = 'Mozilla/5.0 (Windows NT 6.1)'\
           ' AppleWebKit/537.36 (KHTML, like Gecko)'\
           ' Chrome/42.0.2228.0 Safari/537.36'

    l1 = 'pl-PL,pl;q=0.5'
    l2 = 'en-US,en;q=0.5'

    a1 = create(:user_agent,
                user: user,
                name: b_v1,
                accept_language: l1)

    create(:user_agent,
           user: user,
           name: b_v2,
           accept_language: l2)

    expect { subject.call }.
        to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'do not notify when only lang changes' do
    l1 = 'pl-PL,pl;q=0.5'
    l2 = 'en-US,en;q=0.5'

    a1 = create(:user_agent,
                user: user,
                accept_language: l1)

    create(:user_agent,
           user: user,
           name: a1.name,
           accept_language: l2)

    expect { subject.call }.
        to_not(change { ActionMailer::Base.deliveries.count })
  end
end
