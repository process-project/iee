# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ResourceAccessPoliciesDecorator do
  it 'groups user access policies' do
    u1, u2 = create_list(:user, 2)
    group = create(:group)
    am1, am2 = create_list(:access_method, 2)
    resource = create(:resource)
    ap1 = AccessPolicy.create!(resource: resource, user: u1, access_method: am1)
    ap2 = AccessPolicy.create!(resource: resource, user: u1, access_method: am2)
    ap3 = AccessPolicy.create!(resource: resource, user: u2, access_method: am1)
    AccessPolicy.create!(resource: resource, group: group, access_method: am1)

    user_access_policies = described_class.new(resource, AccessPolicy.new).
                           user_access_policies

    expect(user_access_policies.size).to eq(2)
    expect(user_access_policies[u1.email]).to contain_exactly(ap1, ap2)
    expect(user_access_policies[u2.email]).to contain_exactly(ap3)
  end

  it 'groups group access policies' do
    user = create(:user)
    g1, g2 = create_list(:group, 2)
    am1, am2 = create_list(:access_method, 2)
    resource = create(:resource)
    ap1 = AccessPolicy.create!(resource: resource, group: g1, access_method: am1)
    ap2 = AccessPolicy.create!(resource: resource, group: g1, access_method: am2)
    ap3 = AccessPolicy.create!(resource: resource, group: g2, access_method: am1)
    AccessPolicy.create!(resource: resource, user: user, access_method: am1)

    group_access_policies = described_class.new(resource, AccessPolicy.new).
                            group_access_policies

    expect(group_access_policies.size).to eq(2)
    expect(group_access_policies[g1.name]).to contain_exactly(ap1, ap2)
    expect(group_access_policies[g2.name]).to contain_exactly(ap3)
  end
end
