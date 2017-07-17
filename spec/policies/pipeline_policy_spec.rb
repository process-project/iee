# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PipelinePolicy do
  subject { described_class }

  permissions :new?, :create?, :show? do
    it 'grants access to everyone' do
      expect(subject).to permit(create(:user), build(:pipeline))
    end
  end

  permissions :update?, :destroy?, :edit? do
    it 'grants access to pipeline owner' do
      owner = create(:user)

      expect(subject).to permit(owner, build(:pipeline, user: owner))
    end

    it 'grants access to admin' do
      expect(subject).to permit(create(:admin), build(:pipeline))
    end

    it 'denies access for non pipeline owner' do
      expect(subject).to_not permit(create(:user), build(:pipeline))
    end
  end
end
