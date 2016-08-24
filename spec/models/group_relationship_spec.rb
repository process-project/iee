# frozen_string_literal: true
require 'rails_helper'

RSpec.describe GroupRelationship do
  it 'denies direct cycle' do
    group = create(:group)

    expect(GroupRelationship.new(child: group, parent: group)).to be_invalid
  end

  it 'denies complex cycle' do
    parent = create(:group)
    child = create(:group, parents: [parent])

    expect(GroupRelationship.new(child: parent, parent: child)).to be_invalid
  end
end
