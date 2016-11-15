# frozen_string_literal: true
class GroupsController < ApplicationController
  before_action :find_group_and_authorize,
                only: [:destroy, :update]

  def index
    @groups = policy_scope(Group).order(:name)
  end

  def show
    @group = Group.includes(:users, :children, :parents).find(params[:id])
    authorize(@group)
  end

  def new
    @group = Group.new
    authorize(@group)
  end

  def create
    @group = Group.new(permitted_attributes(Group))
    @group.user_groups.build(user: current_user, owner: true)
    authorize(@group)

    if @group.save
      redirect_to(group_path(@group))
    else
      render(:new)
    end
  end

  def edit
    @group = Group.includes(:parents).find(params[:id])
    authorize(@group)
  end

  def update
    if @group.update_attributes(permitted_attributes(@group))
      redirect_to(group_path(@group))
    else
      render(:edit, status: :bad_request)
    end
  rescue ActiveRecord::RecordInvalid
    @group.errors.add(:child_ids,
                      I18n.t('activerecord.errors.models.group.child_ids.cycle'))
    render(:edit, status: :bad_request)
  end

  def destroy
    @group.destroy
    redirect_to(groups_path)
  end

  private

  def find_group_and_authorize
    @group = Group.find(params[:id])
    authorize(@group)
  end
end
