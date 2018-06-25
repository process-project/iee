# frozen_string_literal: true

require 'rails_helper'

describe Audits::Create do
  let(:user) { create(:user) }

  subject { described_class.new(user) }

  it 'creates new IP in the DB' do
    ip = Faker::Internet.public_ip_v4_address
    ua = Faker::Internet.user_agent
    c = Faker::Lorem.characters(2)
    lang = "#{c.downcase}-#{c},#{c.downcase};q=0.#{Faker::Number.between(1, 9)}"

    expect { subject.call ip,ua,lang }.
      to change { Ip.count }.by(1)
  end

  it 'saves proper IP in the DB' do
    ip = Faker::Internet.public_ip_v4_address
    ua = Faker::Internet.user_agent
    c = Faker::Lorem.characters(2)
    lang = "#{c.downcase}-#{c},#{c.downcase};q=0.#{Faker::Number.between(1, 9)}"

    subject.call ip,ua,lang

    expect(Ip.last.address).to eq(ip)
  end

  it 'creates new user_agent in the DB' do
    ip = Faker::Internet.public_ip_v4_address
    ua = Faker::Internet.user_agent
    c = Faker::Lorem.characters(2)
    lang = "#{c.downcase}-#{c},#{c.downcase};q=0.#{Faker::Number.between(1, 9)}"

    expect { subject.call ip,ua,lang }.
        to change { UserAgent.count }.by(1)
  end

  it 'saves proper user_agent name in the DB' do
    ip = Faker::Internet.public_ip_v4_address
    ua = Faker::Internet.user_agent
    c = Faker::Lorem.characters(2)
    lang = "#{c.downcase}-#{c},#{c.downcase};q=0.#{Faker::Number.between(1, 9)}"

    subject.call ip,ua,lang

    expect(UserAgent.last.name).to eq(ua)
  end

  it 'saves proper user_agent lang in the DB' do
    ip = Faker::Internet.public_ip_v4_address
    ua = Faker::Internet.user_agent
    c = Faker::Lorem.characters(2)
    lang = "#{c.downcase}-#{c},#{c.downcase};q=0.#{Faker::Number.between(1, 9)}"

    subject.call ip,ua,lang

    expect(UserAgent.last.accept_language).to eq(lang)
  end
end