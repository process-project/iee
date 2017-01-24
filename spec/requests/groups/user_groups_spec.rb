# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Group members' do
  let(:user) { create(:approved_user) }
  let(:group) { create(:group) }

  before { login_as(group.users.first) }

  describe 'POST /groups/:group_id/user_groups' do
    it 'allows adding normal users into managed group' do
      u1, u2 = create_list(:approved_user, 2)

      expect do
        post group_user_groups_path(group),
             params: { user_group: { user_id: [u1.id, u2.id] } }
      end.to change { UserGroup.count }.by(2)

      expect(group.user_groups.find_by(user: u1).owner).to be_falsy
      expect(group.user_groups.find_by(user: u2).owner).to be_falsy
    end

    it 'allows adding owners into managed group' do
      u = create(:approved_user)

      post group_user_groups_path(group),
           params: { user_group: { user_id: [u.id], owner: true } }

      expect(group.user_groups.find_by(user: u).owner).to be_truthy
    end

    it 'denies adding user to not managed group' do
      post group_user_groups_path(create(:group)),
           params: { user_group: { user_id: [create(:approved_user).id] } }

      expect(response.status).to eq(302)
    end

    it 'update from normal user to owner' do
      u = create(:approved_user)
      ug = UserGroup.create(group: group, user: u, owner: false)

      expect do
        post group_user_groups_path(group),
             params: { user_group: { user_id: [u.id], owner: true } }
      end.to change { ug.reload.owner }.from(false).to(true)
    end

    it 'cannot downgrade owner into member' do
      u = create(:approved_user)
      ug = UserGroup.create(group: group, user: u, owner: true)

      expect do
        post group_user_groups_path(group),
             params: { user_group: { user_id: [u.id], owner: false } }
      end.not_to change { ug.reload.owner }
    end

    it 'does not allow to add new members by normal member' do
      group = create(:group)
      UserGroup.create(group: group, user: user, owner: false)

      post group_user_groups_path(group),
           params: { user_group: { user_id: [create(:approved_user).id], owner: false } }

      expect(flash[:alert]).
        to include('You are not authorized to perform this action')
    end
  end

  describe 'DELETE /groups/:group_id/user_groups/:id' do
    it 'allows to delete user from managed group' do
      u = create(:approved_user)
      ug = UserGroup.create(user: u, group: group, owner: false)

      expect { delete group_user_group_path(group, ug) }.
        to change { UserGroup.count }.by(-1)

      expect(group.user_groups.find_by(user: u)).to be_nil
    end

    it 'denies removing user from not managed group' do
      group = create(:group)
      ug = UserGroup.create(user: create(:approved_user), group: create(:group), owner: false)

      delete group_user_group_path(group, ug)

      expect(response.status).to eq(302)
    end

    it 'denies to remove last group owner' do
      ug = group.user_groups.find_by(owner: true)

      expect { delete group_user_group_path(group, ug) }.
        not_to change { UserGroup.count }
    end
  end
end
