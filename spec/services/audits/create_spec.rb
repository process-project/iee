# frozen_string_literal: true

require 'rails_helper'

describe Audits::Create do
  let(:user) { create(:user) }

  subject { described_class.new(user) }

  it 'creates new IP in the DB' do
    ua = build(:user_agent, user: user)
    ip = build(:ip, user_agent: ua)

    expect { subject.call ip.address, ua.name, ua.accept_language }.
      to change { Ip.count }.by(1)
  end

  it 'saves proper IP in the DB' do
    ua = build(:user_agent, user: user)
    ip = build(:ip, user_agent: ua)

    subject.call ip.address, ua.name, ua.accept_language

    expect(Ip.last.address).to eq(ip.address)
  end

  it 'creates new user_agent in the DB' do
    ua = build(:user_agent, user: user)
    ip = build(:ip, user_agent: ua)

    expect { subject.call ip.address, ua.name, ua.accept_language }.
      to change { UserAgent.count }.by(1)
  end

  it 'saves proper user_agent name in the DB' do
    ua = build(:user_agent, user: user)
    ip = build(:ip, user_agent: ua)

    subject.call ip.address, ua.name, ua.accept_language

    expect(UserAgent.last.name).to eq(ua.name)
  end

  it 'saves proper user_agent lang in the DB' do
    ua = build(:user_agent, user: user)
    ip = build(:ip, user_agent: ua)

    subject.call ip.address, ua.name, ua.accept_language

    expect(UserAgent.last.accept_language).to eq(ua.accept_language)
  end
end
