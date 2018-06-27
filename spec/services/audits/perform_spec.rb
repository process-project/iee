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
                :chrome,
                user: user)

    create(:user_agent,
           :firefox,
           user: user,
           accept_language: a1.accept_language)

    expect { subject.call }.
      to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'do not notify when browser was previously used' do
    create(:ip, user: user)
    a1 = create(:user_agent,
                :chrome,
                user: user)

    create(:user_agent,
           :firefox,
           user: user,
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
    # PL IP
    create(:ip,
           user: user)

    # Other PL IP
    create(:ip,
           user: user)

    expect { subject.call }.
      to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'notify when ip\'s country changes' do
    create(:user_agent, user: user)
    # PL IP
    create(:ip,
           user: user)

    # US IP
    create(:ip,
           :us,
           user: user)

    expect { subject.call }.
      to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'do not notify when ip\'s country was previously used' do
    create(:user_agent, user: user)
    # PL IP
    create(:ip,
           user: user)

    # US IP
    create(:ip,
           :us,
           user: user)

    # Other PL IP
    create(:ip,
           user: user)

    expect { subject.call }.
      to_not(change { ActionMailer::Base.deliveries.count })
  end
end
