require 'rails_helper'

describe UserGroupsWithAncestors do
  let(:user) { create(:user) }

  context 'user has no associated group' do
    it 'returns empty array' do
      expect(UserGroupsWithAncestors.new(user).get).to eq []
    end
  end

  context 'user has one group' do
    let!(:group) { create(:group, users: [user]) }
    it 'returns an array with associated group' do
      expect(UserGroupsWithAncestors.new(user).get).to eq [group]
    end
  end

  context 'users has many groups with ancestors' do
    let!(:grandpa) { create(:group) }
    let!(:parent) { create(:group, parent_group: grandpa) }
    let!(:child) { create(:group, parent_group: parent, users: [user]) }
    let!(:group) { create(:group, users: [user]) }

    it 'return an array with associated groups with ancestors' do
      group_set = UserGroupsWithAncestors.new(user).get.to_set

      expect(group_set).to eq [group, child, parent, grandpa].to_set
    end
  end
end