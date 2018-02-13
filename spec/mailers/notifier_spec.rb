# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notifier do
  include ProxySpecHelper

  describe 'user registered' do
    let(:user) { create(:user) }
    let(:mail) { described_class.user_registered(user).deliver_now }

    it 'don\'t send email when no supervisors' do
      expect { mail }.to_not(change { ActionMailer::Base.deliveries.count })
    end

    it 'send email to all supervisors' do
      s1, s2 = create_supervisors(2)

      expect { mail }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(mail.to).to contain_exactly(s1.email, s2.email)
    end

    it 'assings new user @name' do
      create_supervisors

      expect(mail.body.encoded).to match(ERB::Util.html_escape(user.name))
    end

    def create_supervisors(supervisors_count = 1)
      supervisor_group = build(:group, name: 'supervisor')
      create_list(:user, supervisors_count).tap do |users|
        users.each { |u| supervisor_group.user_groups.build(user: u, owner: true) }
        supervisor_group.save!
      end
    end
  end

  describe 'account approved' do
    it 'sends email to account owner' do
      user = build(:user)

      mail = described_class.account_approved(user).deliver_now

      expect(mail.body.encoded).to match('has been approved')
    end
  end

  describe 'proxy has expired' do
    it 'sends email to proxy owner' do
      user = build(:user, proxy: outdated_proxy)

      mail = described_class.proxy_expired(user).deliver_now

      expect(mail.to).to contain_exactly(user.email)
      expect(mail.body.encoded).to match('proxy certificate has expired')
    end
  end

  describe 'audit failed' do
    it 'sends email to account owner' do
      user_audit = build(:user_audit)

      mail = described_class.audit_failed(user_audit).deliver_now

      expect(mail.body.encoded).to match('detected unusual authentication')
    end
  end
end
