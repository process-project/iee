# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ServicePolicy do
  let(:user) { create(:user) }
  let(:service) { create(:service) }

  subject { ServicePolicy.new(user, service) }

  describe '#update?' do
    it 'allows updates on owned resources' do
      user.services << service
      expect(subject.update?).to be_truthy
    end

    it 'blocks updates on not owned resources' do
      expect(subject.update?).to be_falsey
    end
  end
end
