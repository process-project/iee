# frozen_string_literal: true

require 'rails_helper'

describe Audits::Perform do
  let(:user) { create(:user) }

  subject { described_class.new(user) }

  it 'do not notify when ip is the same' do
    ua = create(:user_agent, user: user)
    ip1 = create(:ip, user_agent: ua)

    create(:ip,
           user_agent: ua,
           address: ip1.address)

    expect { subject.call }.
      to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'do not notify when user agent is the same' do
    a1 = create(:user_agent, user: user)
    create(:ip, user_agent: a1)

    create(:user_agent,
           user: user,
           name: a1.name,
           accept_language: a1.accept_language)

    expect { subject.call }.
      to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'notify when browser changes' do
    a1 = create(:user_agent,
                :chrome,
                user: user)
    create(:ip, user_agent: a1)

    create(:user_agent,
           :firefox,
           user: user,
           accept_language: a1.accept_language)

    expect { subject.call }.
      to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'do not notify when browser was previously used' do
    a1 = create(:user_agent,
                :chrome,
                user: user)

    create(:ip, user_agent: a1)

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
    ua = create(:user_agent, user: user)
    # PL IP
    create(:ip,
           user_agent: ua)

    # Other PL IP
    create(:ip,
           user_agent: ua)

    expect { subject.call }.
      to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'notify when ip\'s country changes' do
    ua = create(:user_agent, user: user)
    # PL IP
    create(:ip,
           user_agent: ua)

    # US IP
    create(:ip,
           :us,
           user_agent: ua)

    expect { subject.call }.
      to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'do not notify when ip\'s country was previously used' do
    ua = create(:user_agent, user: user)
    # PL IP
    create(:ip,
           user_agent: ua)

    # US IP
    create(:ip,
           :us,
           user_agent: ua)

    # Other PL IP
    create(:ip,
           user_agent: ua)

    expect { subject.call }.
      to_not(change { ActionMailer::Base.deliveries.count })
  end
end
