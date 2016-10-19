# frozen_string_literal: true
module Groups
  class UserGroupsController < ApplicationController
    before_action :find_group_and_authorize

    def create
      attrs = permitted_attributes(UserGroup)
      owner = attrs[:owner] || false
      User.where(id: attrs[:user_id]).each do |user|
        user_group(user).owner ||= owner
      end

      @group.save ? redirect_to_group : render_errors
    end

    def destroy
      user_group = @group.user_groups.find(params[:id])
      authorize(user_group)

      if last_admin?(user_group)
        redirect_to_group(alert: I18n.t('errors.user_groups.last_owner'))
      else
        user_group.destroy!
        redirect_to_group
      end
    end

    private

    def user_group(user)
      @group.user_groups.detect { |ug| ug.user_id == user.id } ||
        @group.user_groups.build(user: user)
    end

    def redirect_to_group(options = {})
      redirect_to group_path(@group), options
    end

    def render_errors
      render('groups/show', status: :bad_request)
    end

    def last_admin?(user_group)
      @group.user_groups.
        where(owner: true).
        where.not(id: user_group.id).
        count.zero?
    end

    def find_group_and_authorize
      @group = Group.includes(:user_groups).find(params[:group_id])
      authorize(@group, :update?)
    end
  end
end
