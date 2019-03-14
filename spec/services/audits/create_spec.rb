# frozen_string_literal: true

require 'rails_helper'

describe Audits::Create do
  let(:user) { create(:user) }

  subject { described_class.new(user) }

  it 'creates new IP in the DB' do
    ua = build(:device, user: user)
    ip = build(:ip, device: ua)

    expect { subject.call ip.address, ua.name, ua.accept_language }.
      to change { Ip.count }.by(1)
  end

  it 'saves proper IP in the DB' do
    ua = build(:device, user: user)
    ip = build(:ip, device: ua)

    subject.call ip.address, ua.name, ua.accept_language

    expect(Ip.last.address).to eq(ip.address)
  end

  it 'creates new device in the DB' do
    ua = build(:device, user: user)
    ip = build(:ip, device: ua)

    expect { subject.call ip.address, ua.name, ua.accept_language }.
      to change { Device.count }.by(1)
  end

  it 'saves proper device name in the DB' do
    ua = build(:device, user: user)
    ip = build(:ip, device: ua)

    subject.call ip.address, ua.name, ua.accept_language

    expect(Device.last.name).to eq(ua.name)
  end

  it 'saves proper device lang in the DB' do
    ua = build(:device, user: user)
    ip = build(:ip, device: ua)

    subject.call ip.address, ua.name, ua.accept_language

    expect(Device.last.accept_language).to eq(ua.accept_language)
  end

  it 'creates device which is user scoped' do
    ua = build(:device, user: user)
    ip = build(:ip, device: ua)
    other_user = create(:user)

    subject.call ip.address, ua.name, ua.accept_language
    described_class.new(other_user).call(ip.address, ua.name, ua.accept_language)

    expect(other_user.devices.count).to eq(1)
  end
end
