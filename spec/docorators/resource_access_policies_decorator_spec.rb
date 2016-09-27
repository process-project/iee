# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ResourceAccessPoliciesDecorator do
  let(:resource) { create(:resource) }

  describe '#user_access_policies' do
    it 'groups user access policies' do
      u1, u2 = create_list(:user, 2)
      group = create(:group)
      am1, am2 = create_list(:access_method, 2)
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
  end

  describe '#group_access_policies' do
    it 'groups group access policies' do
      user = create(:user)
      g1, g2 = create_list(:group, 2)
      am1, am2 = create_list(:access_method, 2)
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

  describe '#access_methods' do
    it 'returns only methods available for this service policies' do
      global_am = create(:access_method)
      local_am = create(:access_method, service: resource.service)
      create(:access_method, :service_scoped) # unavailable access method

      expect(described_class.new(resource, AccessPolicy.new).access_methods).
        to match_array [global_am, local_am]
    end
  end
end
