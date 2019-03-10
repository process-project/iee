# frozen_string_literal: true

require 'rails_helper'

describe Audits::Perform do
  let(:user) { create(:user) }

  subject { described_class.new(user) }

  it 'do not notify when ip is the same' do
    ua = create(:device, user: user)
    ip1 = create(:ip, device: ua)

    create(:ip,
           device: ua,
           address: ip1.address)

    expect { subject.call }.
      to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'do not notify when device is the same' do
    a1 = create(:device, user: user)
    create(:ip, device: a1)

    create(:device,
           user: user,
           name: a1.name,
           accept_language: a1.accept_language)

    expect { subject.call }.
      to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'notify when browser changes' do
    a1 = create(:device,
                :chrome,
                user: user)
    ip1 = create(:ip,
                 device: a1)

    a2 = create(:device,
                :firefox,
                user: user,
                accept_language: a1.accept_language)
    create(:ip,
           device: a2,
           address: ip1.address)

    expect { subject.call }.
      to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'do not notify when browser was previously used' do
    a1 = create(:device,
                :chrome,
                user: user)

    create(:ip, device: a1)

    create(:device,
           :firefox,
           user: user,
           accept_language: a1.accept_language)

    create(:device,
           user: user,
           name: a1.name,
           accept_language: a1.accept_language)

    expect { subject.call }.
      to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'do not notify when ip\'s country is the same' do
    ua = create(:device, user: user)
    # PL IP
    create(:ip,
           device: ua)

    # Other PL IP
    create(:ip,
           device: ua)

    expect { subject.call }.
      to_not(change { ActionMailer::Base.deliveries.count })
  end

  it 'notify when ip\'s country changes' do
    ua = create(:device, user: user)
    # PL IP
    create(:ip,
           device: ua)

    # US IP
    create(:ip,
           :us,
           device: ua)

    expect { subject.call }.
      to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'do not notify when ip\'s country was previously used' do
    ua = create(:device, user: user)
    # PL IP
    create(:ip,
           device: ua)

    # US IP
    create(:ip,
           :us,
           device: ua)

    # Other PL IP
    create(:ip,
           device: ua)

    expect { subject.call }.
      to_not(change { ActionMailer::Base.deliveries.count })
  end
end
