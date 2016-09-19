# frozen_string_literal: true
class GroupsController < ApplicationController
  before_action :find_group_and_authorize,
                only: [:show, :edit, :destroy, :update]

  def index
    @groups = policy_scope(Group).order(:name)
  end

  def show
  end

  def new
    @group = Group.new
    authorize(@group)
  end

  def create
    @group = Group.new(create_params)
    authorize(@group)

    if @group.save
      redirect_to(group_path(@group))
    else
      render(:edit)
    end
  end

  def edit
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

  def create_params
    attrs = permitted_attributes(Group)
    attrs[:owner_ids] ||= []
    attrs[:owner_ids] << current_user.id

    attrs
  end

  def find_group_and_authorize
    @group = Group.find(params[:id])
    authorize(@group)
  end
end