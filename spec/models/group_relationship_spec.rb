# frozen_string_literal: true
require 'rails_helper'

RSpec.describe GroupRelationship, type: :model do
  it 'denies to create cycle' do
    grandpa = create(:group)
    parent = create(:group, parents: [grandpa])
    child = create(:group, parents: [parent])

    relationship = GroupRelationship.new(child: grandpa, parent: child)

    expect(relationship).to_not be_valid
  end

  it 'allow to create separete group hierarhies with shared element' do
    child, parent1, parent2 = create_list(:group, 3)
    GroupRelationship.create!(child: child, parent: parent1)

    relationship = GroupRelationship.new(child: child, parent: parent2)

    expect(relationship).to be_valid
  end
end
