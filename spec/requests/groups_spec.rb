# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Groups controller' do
  it 'don\'t allow to enter anonyous user' do
    get groups_path
    expect(response).to redirect_to new_user_session_path
  end

  context 'with user signed in' do
    let(:user) { create(:user, :approved) }

    before { login_as(user) }

    describe 'GET /groups' do
      it 'show empty msg when not groups defined' do
        get groups_path

        expect(response.body).to include(I18n.t('groups.index.nothing'))
      end

      it 'shows all defined groups' do
        create(:group, name: 'g1')
        group_with_user(managed: false, name: 'g2')
        group_with_user(managed: true, name: 'g3')

        get groups_path

        expect(response.body).to include('g1')
        expect(response.body).to include('g2')
        expect(response.body).to include('g3')
      end
    end

    describe 'SHOW /groups/:id' do
      it 'allows to show non owned group' do
        group = create(:group, name: 'g1')

        get group_path(group)

        expect(response.status).to eq(200)
      end
    end

    describe 'POST /groups' do
      it 'assign group attributes' do
        post groups_path, params: { group: { name: 'my_group' } }

        new_group = Group.last

        expect(new_group.name).to eq('my_group')
      end

      it 'assign current user as an owner of new created group' do
        post groups_path, params: { group: { name: 'my_group' } }

        new_group = Group.last

        expect(new_group.user_groups.where(user: user, owner: true)).to be_exist
      end
    end

    describe 'POST /groups/:id' do
      it 'denies to update not owned group' do
        group = create(:group)

        put group_path(group), params: { group: { name: 'new_name' } }

        expect(response.status).to eq(403)
      end

      it 'updates group attributes for managed group' do
        group = group_with_user(managed: true, name: 'old_name')
        u1, u2 = create_list(:user, 2)

        put group_path(group),
            params: { group: {
              name: 'new_name',
              owner_ids: [u1.id],
              member_ids: [u2.id]
            } }
        group.reload

        expect(group.name).to eq('new_name')
        expect(group.user_groups.find_by(user: u1).owner).to be_truthy
        expect(group.user_groups.find_by(user: u2).owner).to be_falsy
      end
    end

    describe 'DELETE /groups/:id' do
      it 'denies to destroy not owned group' do
        group = create(:group)

        delete group_path(group)

        expect(response.status).to eq(403)
      end

      it 'destroys managed group' do
        group = group_with_user(managed: true, name: 'my_group')

        expect { delete group_path(group) }.to change { Group.count }.by(-1)
      end
    end
  end

  def group_with_user(managed:, name:)
    group = create(:group, name: name)
    group.user_groups.create(user: user, owner: managed)

    group
  end
end
