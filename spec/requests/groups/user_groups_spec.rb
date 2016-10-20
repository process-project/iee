# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Group members' do
  let(:user) { create(:approved_user) }

  before { login_as(user) }

  describe 'POST /groups/:group_id/user_groups' do
    it 'allows adding normal users into managed group' do
      u1, u2 = create_list(:approved_user, 2)
      group = create(:group)
      UserGroup.create(group: group, user: user, owner: true)

      expect do
        post group_user_groups_path(group),
             params: { user_group: { user_id: [u1.id, u2.id] } }
      end.to change { UserGroup.count }.by(2)

      expect(group.user_groups.find_by(user: u1).owner).to be_falsy
      expect(group.user_groups.find_by(user: u2).owner).to be_falsy
    end

    it 'allows adding owners into managed group' do
      u = create(:approved_user)
      group = create(:group)
      UserGroup.create(group: group, user: user, owner: true)

      post group_user_groups_path(group),
           params: { user_group: { user_id: [u.id], owner: true } }

      expect(group.user_groups.find_by(user: u).owner).to be_truthy
    end

    it 'denies adding user to not managed group' do
      u = create(:approved_user)
      group = create(:group)

      post group_user_groups_path(group),
           params: { user_group: { user_id: [u.id] } }

      expect(response.status).to eq(302)
    end

    it 'update from normal user to owner' do
      u = create(:approved_user)
      group = create(:group)
      UserGroup.create(group: group, user: user, owner: true)
      ug = UserGroup.create(group: group, user: u, owner: false)

      post group_user_groups_path(group),
           params: { user_group: { user_id: [u.id], owner: true } }
      ug.reload

      expect(ug).to be_owner
    end

    it 'cannot downgrade owner into member' do
      u = create(:approved_user)
      group = create(:group)
      UserGroup.create(group: group, user: user, owner: true)
      ug = UserGroup.create(group: group, user: u, owner: true)

      post group_user_groups_path(group),
           params: { user_group: { user_id: [u.id], owner: false } }
      ug.reload

      expect(ug).to be_owner
    end
  end

  describe 'DELETE /groups/:group_id/user_groups/:id' do
    it 'allows to delete user from managed group' do
      u = create(:approved_user)
      group = create(:group)
      UserGroup.create(user: user, group: group, owner: true)
      ug = UserGroup.create(user: u, group: group, owner: false)

      expect { delete group_user_group_path(group, ug) }.
        to change { UserGroup.count }.by(-1)

      expect(group.user_groups.find_by(user: u)).to be_nil
    end

    it 'denies removing user from not managed group' do
      u = create(:approved_user)
      group = create(:group)
      ug = UserGroup.create(user: u, group: group, owner: false)

      delete group_user_group_path(group, ug)

      expect(response.status).to eq(302)
    end

    it 'denies to remove last group owner' do
      group = create(:group)
      ug = group.user_groups.find_by(owner: true)

      expect { delete group_user_group_path(group, ug) }.
        to change { UserGroup.count }.by(0)
    end
  end
end
