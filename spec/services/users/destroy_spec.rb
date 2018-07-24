# frozen_string_literal: true

require 'rails_helper'

describe Users::Destroy do
  let!(:current_user) { create(:user) }

  it 'removes user from database' do
    user = create(:user)

    expect do
      described_class.new(current_user, user).call
    end.to change { User.count }.by(-1)
  end

  it 'returns :ok when user is removed' do
    result = described_class.new(current_user, create(:user)).call
    expect(result).to eq(:ok)
  end

  it 'is fobidden to remove self' do
    expect do
      described_class.new(current_user, current_user).call
    end.to change { User.count }.by(0)
  end

  it 'returns :self when trying to remove self' do
    result = described_class.new(current_user, current_user).call
    expect(result).to eq(:self)
  end

  it 'is forbidden to remove last group owner' do
    user = user_with_exclusively_owner_group

    expect do
      described_class.new(current_user, user).call
    end.to change { User.count }.by(0)
  end

  it 'returns :last_group_owner when there is exclusively owned group by the user' do
    user = user_with_exclusively_owner_group

    result = described_class.new(current_user, user).call

    expect(result).to eq(:last_group_owner)
  end

  def user_with_exclusively_owner_group
    create(:user).tap do |user|
      group = build(:group)
      group.user_groups.build(user: user, owner: true)
      group.save!
    end
  end
end
