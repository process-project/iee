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
    valid = true
    @resource = Resource.find_by(id: params[:permission][:resource_id])
    
    if !(params[:permission][:user_id].empty? ^ params[:permission][:group_id].empty?)
      @permission.errors.add(:user_id, t("either_user_or_group"))
      valid = false
    end
    
    if params[:permission][:action_id].nil? || params[:permission][:action_id].empty?
      @permission.errors.add(:action_id, t("missing_action"))
      valid = false
    end
    
    set_other_fields
      
    if valid && @permission.save
      redirect_to new_permission_path(resource_id: params[:permission][:resource_id])
    else
      render :new
    end
  end
  
  private
  
  def set_other_fields
    @users = User.approved
    @groups = Group.all
    @actions = Action.all
    
    @user_permissions = {}
    User.joins(permissions: :resource).includes(permissions: :action)
        .where(resources: {id: @resource.id}).each do |user|
      @user_permissions[user.email] = user.permissions.map { |permission| permission.action.name }  
    end
    
    @group_permissions = {}
    Group.joins(permissions: :resource).includes(permissions: :action)
        .where(resources: {id: @resource.id}).each do |group|
      @group_permissions[group.name] = group.permissions.map { |permission|
        permission.action.name }
    end
  end
  
  def permission_params
    params.require(:permission).permit(policy(Permission).permitted_attributes)
  end
end
