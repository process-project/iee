# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserAgentPolicy do
  subject { described_class }

  permissions :show? do
    let(:user) { create(:user) }
    let(:user_agent) { create(:user_agent, user: user) }

    it 'grants access for the owner' do
      expect(subject).to permit(user, user_agent)
    end

    it 'grants access for vapor supervisor' do
      expect(subject).to permit(create(:supervisor_user), user_agent)
    end

    it 'grants access for vapor admin' do
      expect(subject).to permit(create(:admin), user_agent)
    end

    it 'denies access for not service owner' do
      expect(subject).to_not permit(create(:user), user_agent)
    end
  end

  context 'scope' do
    it 'shows all user agents for admin' do
      admin = create(:admin)
      ua1 = create(:user_agent, user: admin)
      ua2 = create(:user_agent)

      result = UserAgentPolicy::Scope.new(admin, UserAgent).resolve

      expect(result).to contain_exactly(ua1, ua2)
    end

    it 'shows all user agents for supervisor' do
      supervisor = create(:supervisor_user)
      ua1 = create(:user_agent, user: supervisor)
      ua2 = create(:user_agent)

      result = UserAgentPolicy::Scope.new(supervisor, UserAgent).resolve

      expect(result).to contain_exactly(ua1, ua2)
    end

    it 'shows only owned user agents for normal user' do
      user = create(:user)
      owned = create(:user_agent, user: user)
      create(:user_agent)

      result = UserAgentPolicy::Scope.new(user, UserAgent).resolve

      expect(result).to contain_exactly(owned)
    end
  end

end