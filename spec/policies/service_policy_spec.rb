# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ServicePolicy do
  let(:user) { create(:user) }
  let(:service) { create(:service) }

  subject { ServicePolicy }

  permissions :show?, :edit?, :update?, :destroy? do
    it 'grants access only for owned resources' do
      service.users << user
      expect(subject).to permit(user, service)
    end

    it 'denies access for not owned resources' do
      expect(subject).to_not permit(user, service)
    end
  end
end
