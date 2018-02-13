# frozen_string_literal: true

require 'rails_helper'

class TestNotifier
  attr_reader :user
  attr_reader :notified

  def initialize(user)
    @user = user
    @notified = false
  end

  def notify
    @notified = true
  end

end

describe UserAuditor do

  let(:user) { create(:user) }
  let(:notifier) { TestNotifier.new(user) }

  subject { described_class.new(user, notifier) }

  it 'notifier is created' do
    expect(notifier.user).to eq(user)
  end

  it 'notification is false when notifier is created' do
    expect(notifier.notified).to be_falsey
  end

  it 'notification is true after notify' do
    notifier.notify

    expect(notifier.notified).to be_truthy
  end

  it 'do not notify when nothing changes' do
    a1 = create(:user_audit, user: user)
    create(:user_audit, user: user, ip: a1.ip,
           user_agent: a1.user_agent,
           accept_language: a1.accept_language)

    subject.call

    expect(notifier.notified).to be_falsey
  end

  it 'notify when only browser vendor changes' do
    a1 = create(:user_audit, user: user,
                user_agent: Faker::Internet.user_agent(:chrome))
    create(:user_audit, user: user, ip: a1.ip,
           user_agent: Faker::Internet.user_agent(:firefox),
           accept_language: a1.accept_language)

    subject.call

    expect(notifier.notified).to be_truthy
  end

  it 'do not notify when only browser version changes' do
    a1 = create(:user_audit, user: user,
                user_agent: Faker::Internet.user_agent(:chrome))
    create(:user_audit, user: user, ip: a1.ip,
           user_agent: Faker::Internet.user_agent(:chrome),
           accept_language: a1.accept_language)

    subject.call

    expect(notifier.notified).to be_falsey
  end

  it 'do not notify when only ip changes' do
    a1 = create(:user_audit, user: user)
    create(:user_audit, user: user,
           ip: Faker::Internet.public_ip_v4_address,
           user_agent: a1.user_agent,
           accept_language: a1.accept_language)

    subject.call

    expect(notifier.notified).to be_falsey
  end

  it 'do not notify when only ip\'s country changes' do
    # Cyfronet (PL)
    a1 = create(:user_audit, user: user,
                ip: '149.156.11.38')

    # Google (US)
    create(:user_audit, user: user,
           ip: '8.8.8.8',
           user_agent: a1.user_agent,
           accept_language: a1.accept_language)

    subject.call

    expect(notifier.notified).to be_falsey
  end

  it 'notify when ip\'s country and minor browser version changes' do
    b_v1 = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36'
    b_v2 = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2229.0 Safari/537.36'

    # Cyfronet (PL)
    a1 = create(:user_audit, user: user, user_agent: b_v1,
                ip: '149.156.11.38')

    # Google (US)
    create(:user_audit, user: user, user_agent: b_v2,
           ip: '8.8.8.8',
           accept_language: a1.accept_language)

    subject.call

    expect(notifier.notified).to be_truthy
  end

  it 'notify when browser major version and lang changes' do
    b_v1 = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36'
    b_v2 = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2228.0 Safari/537.36'

    l1 = 'pl-PL,pl;q=0.5'
    l2 = 'en-US,en;q=0.5'

    a1 = create(:user_audit, user: user,
                user_agent: b_v1, accept_language: l1)
    create(:user_audit, user: user, ip: a1.ip,
           user_agent: b_v2,
           accept_language: l2)

    subject.call

    expect(notifier.notified).to be_truthy
  end

  it 'do not notify when only lang changes' do
    l1 = 'pl-PL,pl;q=0.5'
    l2 = 'en-US,en;q=0.5'

    a1 = create(:user_audit, user: user,
                accept_language: l1)
    create(:user_audit, user: user, ip: a1.ip,
           user_agent: a1.user_agent,
           accept_language: l2)

    subject.call

    expect(notifier.notified).to be_falsey
  end

end