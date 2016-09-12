# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ServicePolicy do
  let(:user) { create(:user) }
  let(:service) { create(:service) }

  subject { described_class }

  permissions :edit?, :update?, :destroy?, :view_token? do
    it 'grants access for service owner' do
      user.services << service

      expect(subject).to permit(user, service)
    end

    it 'denies access for not service owner' do
      expect(subject).to_not permit(user, service)
    end
  end

  permissions :show? do
    it 'grants access for everyone' do
      expect(subject).to permit(user, service)
    end
  end
end
