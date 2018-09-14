# frozen_string_literal: true

require 'rails_helper'

describe ExclusivelyOwnedGroups do
  it 'returns user owned groups with only one owner' do
    u1, u2, u3 = create_list(:user, 3)
    g1, g2 = build_list(:group, 2)

    g1.user_groups.build(user: u1, owner: true)
    g1.user_groups.build(user: u2, owner: true)
    g1.user_groups.build(user: u3, owner: false)
    g2.user_groups.build(user: u1, owner: true)
    g2.user_groups.build(user: u3, owner: false)
    g1.save!
    g2.save!

    expect(described_class.new(u1).call).to contain_exactly(g2)
    expect(described_class.new(u3).call).to be_empty
  end
end
