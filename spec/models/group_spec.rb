# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Group do
  it { should have_many(:access_policies).dependent(:destroy) }

  it { should have_many(:subgroups) }

  it { should belong_to(:parent_group) }

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
    let!(:grandpa) { create(:group) }
    let!(:parent) { create(:group, parent_group: grandpa) }
    let!(:child) { create(:group, parent_group: parent) }

    it 'is valid' do
      expect(child.valid?).to be_truthy
    end
    it 'returns an array of ancestors for a child' do
      expect(child.ancestors).to eq [parent, grandpa]
    end

    it 'returns an array of offspring for a grandpa' do
      grandpa.reload
      expect(grandpa.offspring).to eq [parent, child]
    end
  end
  context 'ancestors cycle' do
    it 'is not valid' do
      grandpa = create(:group)
      parent = create(:group, parent_group: grandpa)
      child = create(:group, parent_group: parent)
      grandpa.reload
      grandpa.parent_group = child
      expect(grandpa.valid?).to be_falsey
    end
  end

  context 'members and owners' do
    it 'are converted into user_groups' do
      group = create(:group)
      u1, u2, u3 = create_list(:user, 3)

      expect do
        group.update_attributes(member_ids: [u1.id, u2.id],
                                owner_ids: [u2.id, u3.id])
      end.to change { UserGroup.count }.by(3)
    end

    it 'removes user_groups for non existing members and owners' do
      group = create(:group)
      u1, u2, u3 = create_list(:user, 3)

      group.user_groups.create(user: u1, owner: true)
      group.user_groups.create(user: u2, owner: true)
      group.user_groups.create(user: u3, owner: false)

      expect do
        group.update_attributes(member_ids: [], owner_ids: [u1.id])
      end.to change { UserGroup.count }.by(-2)
    end
  end
end
