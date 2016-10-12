# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ResourcePolicy do
  let(:user) { create(:approved_user, first_name: 'tomek') }
  let(:admin) { create(:admin) }
  let(:group) { create(:group, name: 'subgroup', users: [user]) }
  let(:get_method) { create(:access_method, name: 'get') }
  let(:manage_method) { create(:access_method, name: 'manage') }

  describe 'local resource' do
    let(:resource) { create(:resource, name: 'zasób', resource_type: :local) }

    subject { described_class }

    permissions :new?, :create?, :show?, :edit?, :update?, :destroy? do
      it 'grants access to destroy managed resource' do
        create(:user_access_policy,
               access_method: manage_method, user: user, resource: resource)

        expect(subject).to permit(user, resource)
      end

      it 'grants access to destroy resource for admins' do
        expect(subject).to permit(admin, resource)
      end

      it 'denies to destroy not managed resource' do
        create(:user_access_policy,
               access_method: get_method, user: user, resource: resource)

        expect(subject).to_not permit(user, resource)
      end

      it 'grants access for resource service owner' do
        resource.service.users << user

        expect(subject).to permit(user, resource)
      end

      it 'grants access for admins' do
        expect(subject).to permit(admin, resource)
      end

      it 'denies access for not resource service owner' do
        expect(subject).to_not permit(user, resource)
      end
    end
  end

  describe 'global policies' do
    let(:resource) { create(:resource, resource_type: :global) }

    subject { described_class }

    permissions :new?, :create?, :show?, :edit?, :update?, :destroy? do
      it 'grants access for resource service owner' do
        resource.service.users << user

        expect(subject).to permit(user, resource)
      end

      it 'grants access for admins' do
        expect(subject).to permit(admin, resource)
      end

      it 'denies access for not resource service owner' do
        expect(subject).to_not permit(user, resource)
      end
    end
  end

  describe 'pdp' do
    context 'approved user' do
      let(:resource) { create(:resource, name: 'zasób') }

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
        parent_group = create(:group, name: 'parent group', children: [group])
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

    context 'not approved user' do
      let(:user) { create(:user, approved: false) }
      let(:resource) { create(:resource, name: 'zasób') }

      subject { ResourcePolicy.new(user, resource) }

      it 'denies even if user has resource permission' do
        create(:user_access_policy,
               access_method: get_method, user: user, resource: resource)

        expect(subject.permit?('get')).to be_falsy
      end

      it 'denies even if user has group permission' do
        create(:group_access_policy,
               access_method: get_method, group: group, resource: resource)

        expect(subject.permit?('get')).to be_falsy
      end
    end
  end
end
