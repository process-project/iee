require 'rails_helper'

RSpec.describe ResourcePolicy do
  let(:user) { create(:user) }
  let(:group) { create(:group, users: [user]) }
  let(:resource) { create(:resource) }
  let(:get_action) { create(:action, name: 'get') }
  let(:manage_action) { create(:action, name: 'manage') }

  subject { ResourcePolicy.new(user, resource) }

  it 'checks user permission' do
    create_permission(get_action)
    expect(subject.permit?('get')).to be_truthy
  end

  it 'allows all actions when have manage permission' do
    create_permission(manage_action)
    expect(subject.permit?('get')).to be_truthy
  end

  it 'checks user group permission' do
    create_group_permission(get_action)
    expect(subject.permit?('get')).to be_truthy
  end

  it 'allows all actions when have manage permission' do
    create_group_permission(manage_action)
    expect(subject.permit?('get')).to be_truthy
  end

  def create_permission(action)
    create(:user_permission, action: action, user: user, resource: resource)
  end

  def create_group_permission(action)
    create(:group_permission, action: action, group: group, resource: resource)
  end
end
