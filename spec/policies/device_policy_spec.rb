# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DevicePolicy do
  subject { described_class }

  permissions :index? do
    let(:user) { create(:user) }
    let(:device) { create(:device, user: user) }

    it 'grants access for vapor supervisor' do
      expect(subject).to permit(create(:supervisor_user), device)
    end

    it 'grants access for vapor admin' do
      expect(subject).to permit(create(:admin), device)
    end

    it 'denies access for not service owner' do
      expect(subject).to_not permit(create(:user), device)
    end

    it 'denies access for the owner' do
      expect(subject).to_not permit(user, device)
    end
  end

  context 'scope' do
    it 'shows all devices for admin' do
      admin = create(:admin)
      ua1 = create(:device, user: admin)
      ua2 = create(:device)

      result = DevicePolicy::Scope.new(admin, Device).resolve

      expect(result).to contain_exactly(ua1, ua2)
    end

    it 'shows all devices for supervisor' do
      supervisor = create(:supervisor_user)
      ua1 = create(:device, user: supervisor)
      ua2 = create(:device)

      result = DevicePolicy::Scope.new(supervisor, Device).resolve

      expect(result).to contain_exactly(ua1, ua2)
    end
  end
end
