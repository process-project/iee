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

  it 'notify when all changes' do
    create(:user_audit, user: user)
    create(:user_audit, user: user)

    subject.call

    expect(notifier.notified).to be_truthy
  end
end