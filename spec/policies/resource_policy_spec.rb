require 'rails_helper'

RSpec.describe ResourcePolicy do
  let(:user) { create(:user) }
  let(:group) { create(:group, users: [user]) }
  let(:resource) { create(:resource) }
  let(:get_action) { create(:action, name: 'get') }

  subject { ResourcePolicy.new(user, resource) }

  it 'checks user permission' do
    create(:user_permission,
           action: get_action, user: user, resource: resource)

    expect(subject.permit?('get')).to be_truthy
  end

  it 'checks user group permission' do
    create(:group_permission,
           action: get_action, group: group, resource: resource)

    expect(subject.permit?('get')).to be_truthy
  end

  it 'ignore upper/lower action name case' do
    create(:user_permission,
           action: get_action, user: user, resource: resource)

    expect(subject.permit?('GET')).to be_truthy
  end
end
