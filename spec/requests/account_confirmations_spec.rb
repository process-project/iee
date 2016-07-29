# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'AccountConfirmations' do
  context 'with user signed in' do
    let(:user) { create(:supervisor_user) }
    before { login_as(user) }

    describe 'DELETE /account_confirmations/:id' do
      it 'should not allow a supervisor to block himself' do
        expect do
          delete "/account_confirmations/#{user.id}"
        end.not_to change { user.approved }
        expect(user.approved).to be_truthy

        expect(response).to redirect_to(account_confirmations_index_path)
        follow_redirect!
        expect(flash[:alert]).to eq(I18n.t('cannot_block_itself'))
      end
    end
  end
end
