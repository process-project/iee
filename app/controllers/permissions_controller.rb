class PermissionsController < ApplicationController
  def new
    @resource = Resource.find_by(id: params[:resource_id])

    if @resource
      @permission = Permission.new
      set_other_fields
    else
      flash[:alert] = t("resource_not_found")
      redirect_to resources_path
    end
  end

  def create
    @permission = Permission.new(permission_params)
    @resource = Resource.find_by(id: @permission.resource_id)

    if !@resource
      flash[:alert] = t("resource_not_found")
    end

    set_other_fields

    if @permission.save
      redirect_to new_permission_path(resource_id: @permission.resource_id)
    else
      render :new
    end
  end

  def destroy
    permission = Permission.find_by(id: params[:id])

    if permission
      permission.destroy
    end

    redirect_to new_permission_path(resource_id: params[:resource_id])
  end

  private

  def set_other_fields
    @users = User.approved
    @groups = Group.all
    @actions = Action.all

    @user_permissions = {}
    User.joins(permissions: :resource).includes(permissions: :action)
        .where(resources: {id: @resource.id}).each do |user|
      @user_permissions[user.email] = user.permissions.where(resource_id: @resource.id)
    end

    @group_permissions = {}
    Group.joins(permissions: :resource).includes(permissions: :action)
        .where(resources: {id: @resource.id}).each do |group|
      @group_permissions[group.name] = group.permissions.where(resource_id: @resource.id)
    end
  end

  def permission_params
    params.require(:permission).permit(policy(Permission).permitted_attributes)
  end
end
