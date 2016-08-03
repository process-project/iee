# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ResourcePolicy do
  let(:user) { create(:user, first_name: 'tomek') }
  let(:group) { create(:group, name: 'subgroup', users: [user]) }
  let(:resource) { create(:resource, name: 'zasób') }
  let(:get_method) { create(:access_method, name: 'get') }

  subject { ResourcePolicy.new(user, resource) }

  it 'denies user without permission' do
    expect(subject.permit?('get')).to be_falsey
  end

  it 'checks user access policies' do
    create(:user_access_policy,
           access_method: get_method, user: user, resource: resource)

    expect(subject.permit?('get')).to be_truthy
  end

  it 'denies user not associated with group permission' do
    another_group = create(:group)
    create(:access_policy,
           access_method: get_method, group: another_group, resource: resource)

    expect(subject.permit?('get')).to be_falsey
  end

  it 'checks user group permission' do
    create(:group_access_policy,
           access_method: get_method, group: group, resource: resource)

    expect(subject.permit?('get')).to be_truthy
  end

  it 'checks user parent group permission' do
    parent_group = build(:group, name: 'parent group')
    parent_group.subgroups << group
    parent_group.save!
    create(:access_policy,
           access_method: get_method, group: parent_group, resource: resource)
    user.reload
    resource.reload

    expect(subject.permit?('get')).to be_truthy
  end

  it 'ignore upper/lower action name case' do
    create(:user_access_policy,
           access_method: get_method, user: user, resource: resource)

    expect(subject.permit?('GET')).to be_truthy
  end
end
