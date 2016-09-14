# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Group do
  it { should have_many(:access_policies).dependent(:destroy) }

  it { should have_many(:parent_group_relationship).dependent(:destroy) }
  it { should have_many(:child_group_relationship).dependent(:destroy) }

  it { should have_many(:children) }
  it { should have_many(:parents) }

  it { should validate_uniqueness_of(:name) }

  context 'has no ancestors' do
    let(:orphan) { create(:group) }
    it 'is valid' do
      valid_orphan = build(:group)
      expect(valid_orphan.valid?).to be_truthy
    end
    it 'returns empty ancestors array' do
      expect(orphan.ancestors).to eq []
    end
  end

  context 'has no offspring' do
    let(:childless) { create(:group) }
    it 'is valid' do
      valid_childless = build(:group)
      expect(valid_childless.valid?).to be_truthy
    end
    it 'returns empty offspring array' do
      expect(childless.offspring).to eq []
    end
  end

  context 'has ancestors and offspring' do
    let!(:great_grandpa) { create(:group) }
    let!(:grandpa) { create(:group, parents: [great_grandpa]) }
    let!(:parent) { create(:group, parents: [grandpa]) }
    let!(:child) { create(:group, parents: [parent]) }

    it 'is valid' do
      expect(child.valid?).to be_truthy
    end
    it 'returns an array of ancestors for a child' do
      expect(child.ancestors).to match_array [parent, grandpa, great_grandpa]
    end

    it 'returns an array of offspring for a grandpa' do
      grandpa.reload
      expect(grandpa.offspring).to eq [parent, child]
    end
  end

  context 'group cycles' do
    it 'denies complex cycle' do
      parent = create(:group)
      child = create(:group, parents: [parent])

      expect { child.child_ids = [parent.id] }.
        to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'denies direct cycle' do
      group = create(:group)

      expect { group.child_ids = [group.id] }.
        to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context 'members and owners' do
    it 'are converted into user_groups' do
      group = create(:group)
      u1 = group.user_groups.first.user
      u2, u3 = create_list(:user, 2)

      expect do
        group.update_attributes(member_ids: [u1.id, u2.id],
                                owner_ids: [u2.id, u3.id])
      end.to change { UserGroup.count }.by(2)
    end

    it 'removes user_groups for non existing members and owners' do
      group = build(:group)
      u1, u2, u3 = create_list(:user, 3)

      group.user_groups.build(user: u1, owner: true)
      group.user_groups.build(user: u2, owner: true)
      group.user_groups.build(user: u3, owner: false)

      group.save!

      expect do
        group.update_attributes(member_ids: [], owner_ids: [u1.id])
      end.to change { UserGroup.count }.by(-2)
    end

    it 'create group with user added as member and owner' do
      user = create(:user)
      group = build(:group, member_ids: [user.id], owner_ids: [user.id])

      group.save!
      user_group = UserGroup.find_by(user: user, group: group)

      expect(user_group).to be_owner
    end

    it 'don\'t allow to create group without owner' do
      group = build(:group)

      expect(group).to_not be_valid
    end
  end
end
