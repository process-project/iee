# frozen_string_literal: true
require 'rails_helper'

describe ApplicationHelper, type: :helper do
  describe '#supervisor?' do
    it 'is a user belongs to supervisor group' do
      user = create(:user, groups: [create(:group, name: 'supervisor')])
      allow(controller).to receive(:current_user).and_return(user)

      expect(supervisor?).to be_truthy
    end

    it 'is not user without supervisor group' do
      user = create(:user)
      allow(controller).to receive(:current_user).and_return(user)

      expect(supervisor?).to be_falsy
    end

    it 'is not anonymous user' do
      allow(controller).to receive(:current_user).and_return(nil)

      expect(supervisor?).to be_falsy
    end
  end
end
