# frozen_string_literal: true

require 'rails_helper'

describe Audits::Perform do
  let(:user) { create(:user) }

  subject { described_class.new(user) }

  it 'do not notify when ip is the same' do
    create(:user_agent, user: user)
    ip1 = create(:ip, user: user)

    create(:ip,
           user: user,
           address: ip1.address)

    expect { subject.call }.
     to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'do not notify when user agent is the same' do
    create(:ip, user: user)
    a1 = create(:user_agent, user: user)

    create(:user_agent,
           user: user,
           name: a1.name,
           accept_language: a1.accept_language)

    expect { subject.call }.
        to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'notify when browser changes' do
    create(:ip, user: user)
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

  it 'do not notify when browser was previously used' do
    create(:ip, user: user)
    a1 = create(:user_agent,
                user: user,
                name: Faker::Internet.user_agent(:chrome))

    create(:user_agent,
           user: user,
           name: Faker::Internet.user_agent(:firefox),
           accept_language: a1.accept_language)

    create(:user_agent,
           user: user,
           name: a1.name,
           accept_language: a1.accept_language)

    expect { subject.call }.
        to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'do not notify when ip\'s country is the same' do
    create(:user_agent, user: user)
    # Cyfronet (PL)
    create(:ip,
           user: user,
           address: '149.156.11.38')

    # Cyfronet - other IP, same country as .38 (PL)
    create(:ip,
           user: user,
           address: '149.156.11.37')

    expect { subject.call }.
        to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'notify when ip\'s country changes' do
    create(:user_agent, user: user)
    # Cyfronet (PL)
    create(:ip,
           user: user,
           address: '149.156.11.38')

    # Google (US)
    create(:ip,
           user: user,
           address: '8.8.8.8')

    expect { subject.call }.
        to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'do not notify when ip\'s country was previously used' do
    create(:user_agent, user: user)
    # Cyfronet (PL)
    create(:ip,
           user: user,
           address: '149.156.11.38')

    # Google (US)
    create(:ip,
           user: user,
           address: '8.8.8.8')

    # Cyfronet - other IP, same country as .38 (PL)
    create(:ip,
           user: user,
           address: '149.156.11.37')

    expect { subject.call }.
        to_not(change { ActionMailer::Base.deliveries.count })
  end
end
