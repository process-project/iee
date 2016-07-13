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
      expect(childless.valid?).to be_truthy
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
end
