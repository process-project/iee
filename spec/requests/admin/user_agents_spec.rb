# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User agents management' do
  describe 'with no user signed in' do
    it 'index redirects to signin url' do
      get '/admin/user_agents'
      expect(response).to redirect_to new_user_session_path
    end

    it 'show redirects to signin url' do
      get '/admin/user_agents/1'
      expect(response).to redirect_to new_user_session_path
    end
  end

  describe 'logged as normal user' do
    let(:user) { create(:approved_user) }
    before { login_as(user) }

    it 'index redirects to signin url' do
      get '/admin/user_agents'
      expect(response).to redirect_to new_user_session_path
    end

    it 'show redirects to signin url' do
      get '/admin/user_agents/1'
      expect(response).to redirect_to new_user_session_path
    end
  end

  describe 'logged as supervisor' do
    let(:supervisor) { create(:supervisor_user) }
    before { login_as(supervisor) }

    it 'index is OK' do
      get '/admin/user_agents'
      expect(response).to be_success
    end

    it 'show is OK' do
      get '/admin/user_agents/1'
      expect(response).to be_success
    end
  end

  describe 'logged as admin' do
    let(:admin) { create(:admin) }
    before { login_as(admin) }

    it 'index is OK' do
      get '/admin/user_agents'
      expect(response).to be_success
    end

    it 'show is OK' do
      get '/admin/user_agents/1'
      expect(response).to be_success
    end
  end

end