# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Users management' do
  describe 'logged as supervisor' do
    let(:supervisor) { create(:supervisor_user) }
    before { login_as(supervisor) }

    it 'can block user' do
      user = create(:user, state: :approved)

      expect { put admin_user_path(user, state: :blocked) }.
        to change { user.reload.state }.from('approved').to('blocked')
    end

    it 'can approve user' do
      user = create(:user, state: :new_account)

      expect { put admin_user_path(user, state: :approved) }.
        to change { user.reload.state }.from('new_account').to('approved')
      expect(flash[:notice]).
        to eq(I18n.t('admin.users.update.success',
                     user: user.name, state: 'approved'))
    end

    it 'cannot block himself' do
      expect { put admin_user_path(supervisor, state: :blocked) }.
        to_not change { supervisor.reload.state }
      expect(flash[:alert]).to eq(I18n.t('admin.users.update.me'))
    end

    it 'cannot remove user' do
      user = create(:user)

      expect { delete admin_user_path(user) }.
        to_not change { User.count }
    end
  end

  describe 'logged as admin' do
    let(:admin) { create(:admin) }
    before { login_as(admin) }

    it 'can remove user' do
      user = create(:user)

      expect { delete admin_user_path(user) }.
        to change { User.count }.by(-1)
      expect(flash[:notice]).
        to eq(I18n.t('admin.users.destroy.success', user: user.name))
      expect(User.find_by(id: user.id)).to be_nil
    end

    it 'cannot remove himself' do
      expect { delete admin_user_path(admin) }.
        to_not change { User.count }
      expect(flash[:alert]).to eq(I18n.t('admin.users.destroy.me'))
    end
  end

  describe 'logged as normal user' do
    let(:user) { create(:approved_user) }
    before { login_as(user) }

    it 'cannot enter users management page' do
      get admin_users_path

      expect(response.status).to eq(302)
    end

    it 'cannot change users state' do
      put admin_user_path(user, state: :blocked)

      expect(response.status).to eq(302)
    end
  end
end
