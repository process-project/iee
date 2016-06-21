require 'rails_helper'

RSpec.describe ResourcePolicy do
  let(:user) { create(:user) }
  let(:group) { create(:group, users: [user]) }
  let(:resource) { create(:resource) }
  let(:get_method) { create(:access_method, name: 'get') }

  subject { ResourcePolicy.new(user, resource) }

  it 'checks user access policies' do
    create(:user_access_policy,
           access_method: get_method, user: user, resource: resource)

    expect(subject.permit?('get')).to be_truthy
  end

  it 'checks user group access_policy' do
    create(:group_access_policy,
           access_method: get_method, group: group, resource: resource)

    expect(subject.permit?('get')).to be_truthy
  end

  it 'ignore upper/lower action name case' do
    create(:user_access_policy,
           access_method: get_method, user: user, resource: resource)

    expect(subject.permit?('GET')).to be_truthy
  end
end
