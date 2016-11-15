# frozen_string_literal: true
require 'rails_helper'

describe Policies::RemovePolicies do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:resource) { create(:resource, resource_type: :local) }
  let(:get_method) { create(:access_method, name: 'get') }

  it 'should delete all access policies and the resource itself when only path is given' do
    create(:access_policy, user: user, resource: resource, access_method: get_method)

    expect do
      described_class.new([resource.path], [], [], []).call
    end.to change { Resource.count }.by(-1)
    expect(AccessPolicy.all.count).to eq(0)
  end

  it 'should remove access policies for a group' do
    create(:access_policy, group: group, resource: resource, access_method: get_method)

    described_class.new([resource.path], [], [group.name], []).call

    expect(AccessPolicy.all.count).to eq(0)
  end

  it 'should remove access policies for given users and groups' do
    create(:access_policy, user: user, resource: resource, access_method: get_method)
    create(:access_policy, group: group, resource: resource, access_method: get_method)

    described_class.new([resource.path], [user.email], [group.name], []).call

    expect(AccessPolicy.count).to eq(0)
  end
end
