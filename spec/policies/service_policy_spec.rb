# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ServicePolicy do
  let(:user) { create(:user) }
  let(:service) { create(:service) }

  subject { described_class }

  permissions :show?, :edit?, :update?, :destroy? do
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
end
