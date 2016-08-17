# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Notifier do
  describe 'user registered' do
    let(:user) { create(:user) }
    let(:mail) { described_class.user_registered(user).deliver_now }

    it 'don\'t send email when no supervisors' do
      expect { mail }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'send email to all supervisors' do
      s1, s2 = create_supervisors(2)

      expect { mail }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(mail.to).to contain_exactly(s1.email, s2.email)
    end

    it 'assings new user @name' do
      create_supervisors

      expect(mail.body.encoded).to match(user.name)
    end

    def create_supervisors(supervisors_count = 1)
      supervisor_group = create(:group, name: 'supervisor')
      create_list(:user, supervisors_count, groups: [supervisor_group])
    end
  end

  describe 'account approved' do
    it 'sends email to account owner' do
      user = build(:user)

      mail = described_class.account_approved(user).deliver_now

      expect(mail.body.encoded).to match('has been approved')
    end
  end
end
