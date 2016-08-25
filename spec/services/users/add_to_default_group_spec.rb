# frozen_string_literal: true
require 'rails_helper'

describe Users::AddToDefaultGroups do
  it 'add users to default groups' do
    g1, g2 = create_list(:group, 2, default: true)
    create(:group, default: false)
    user = create(:user)

    described_class.new(user).call
    user.reload

    expect(user.groups).to contain_exactly(g1, g2)
  end

  it 'does not duplicate user groups' do
    g, = create_list(:group, 2, default: true)
    user = create(:user, groups: [g])

    described_class.new(user).call
    user.reload

    expect(user.user_groups.count).to eq(2)
  end
end
