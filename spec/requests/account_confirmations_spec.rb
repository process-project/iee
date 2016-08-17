# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'AccountConfirmations' do
  context 'logged in supervisor' do
    let(:supervisor) { create(:supervisor_user) }
    before { login_as(supervisor) }

    it 'cannot block himself' do
      expect do
        delete "/account_confirmations/#{supervisor.id}"
      end.not_to change { supervisor.approved }
      expect(supervisor.approved).to be_truthy

      expect(response).to redirect_to(account_confirmations_index_path)
      follow_redirect!
      expect(flash[:alert]).to eq(I18n.t('cannot_block_itself'))
    end

    it 'sends email to the user after confirming his/her account' do
      user = create(:user)

      expect { put approve_user_path(id: user.id) }.
        to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'sends email to all confirmed users' do
      create_list(:user, 2)
      create(:user, approved: true)

      expect { put approve_all_path }.
        to change { ActionMailer::Base.deliveries.count }.by(2)
    end
  end
end
