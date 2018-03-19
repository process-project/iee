# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserAuditPolicy do
  let(:user) { User.new }

  subject { described_class }

  permissions :new?, :create? do
    it 'grants access to everyone' do
      expect(subject).to permit(create(:user), build(:user_audit))
    end
  end

  permissions :index?, :show? do
    it 'grants access to user_audit owner' do
      owner = create(:user)

      expect(subject).to permit(owner, build(:user_audit, user: owner))
    end

    it 'grants access to admin' do
      expect(subject).to permit(create(:admin), build(:user_audit))
    end

    it 'denies access for non user_audit owner' do
      expect(subject).to_not permit(create(:user), build(:user_audit))
    end
  end

  permissions :edit?, :update?, :destroy? do
    it 'grants access to admin' do
      expect(subject).to permit(create(:admin), build(:user_audit))
    end

    it 'denies access to user_audit owner' do
      owner = create(:user)

      expect(subject).to_not permit(owner, build(:user_audit, user: owner))
    end

    it 'denies access for non user_audit owner' do
      expect(subject).to_not permit(create(:user), build(:user_audit))
    end
  end
end
