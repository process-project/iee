# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ServicePolicy do
  subject { described_class }

  permissions :show?, :edit?, :update?, :destroy? do
    let(:user) { create(:user) }
    let(:service) { create(:service) }

    it 'grants access for service owner' do
      service.users << user
      expect(subject).to permit(user, service)
    end

    it 'grants access for vapor admin' do
      expect(subject).to permit(create(:admin), service)
    end

    it 'denies access for not service owner' do
      expect(subject).to_not permit(user, service)
    end
  end

  context 'scope' do
    it 'shows all services for admin' do
      admin = create(:admin)
      s1 = create(:service, users: [admin])
      s2 = create(:service)

      result = ServicePolicy::Scope.new(admin, Service).resolve

      expect(result).to contain_exactly(s1, s2)
    end

    it 'shows only owned services for normal user' do
      user = create(:user)
      owned = create(:service, users: [user])
      create(:service)

      result = ServicePolicy::Scope.new(user, Service).resolve

      expect(result).to contain_exactly(owned)
    end
  end
end
