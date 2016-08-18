# frozen_string_literal: true
require 'rails_helper'

RSpec.describe GroupPolicy do
  let(:user) { create(:user) }

  subject { described_class }

  permissions :edit?, :update?, :destroy? do
    it 'grants access only for managed groups' do
      owned_group = group_with_user(true)

      expect(subject).to permit(user, owned_group)
    end

    it 'denies access for not managed groups' do
      other_group = create(:group)
      not_managed_group = group_with_user(false)

      expect(subject).to_not permit(user, other_group)
      expect(subject).to_not permit(user, not_managed_group)
    end
  end

  it 'returns all groups to the user' do
    create(:group)
    group_with_user(true)
    group_with_user(false)

    scope = described_class::Scope.new(user, Group.all)

    expect(scope.resolve.count).to eq(3)
  end

  def group_with_user(managed)
    group = create(:group)
    group.user_groups.create(user: user, owner: managed)

    group
  end
end
