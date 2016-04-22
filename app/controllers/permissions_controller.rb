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
    puts @permission.to_json
    valid = true
    already_exists = false
    @resource = Resource.find_by(id: @permission.resource_id)
    
    if !@resource
      flash[:alert] = t("resource_not_found")
      valid = false
    end
    
    if !(@permission.user_id.nil? ^ @permission.group_id.nil?)
      @permission.errors.add(:user_id, t("either_user_or_group"))
      valid = false
    end
    
    if @permission.action_id.nil?
      @permission.errors.add(:action_id, t("missing_action"))
      valid = false
    end
    
    if not Permission.find_by(user_id: @permission.user_id, group_id: @permission.group_id,
        action_id: @permission.action_id,
        resource_id: @permission.resource_id).nil?
      already_exists = true
    end
    
    set_other_fields
      
    if already_exists || valid && @permission.save
      redirect_to new_permission_path(resource_id: params[:permission][:resource_id])
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
      @user_permissions[user.email] = user.permissions 
    end
    
    @group_permissions = {}
    Group.joins(permissions: :resource).includes(permissions: :action)
        .where(resources: {id: @resource.id}).each do |group|
      @group_permissions[group.name] = group.permissions
    end
  end
  
  def permission_params
    params.require(:permission).permit(policy(Permission).permitted_attributes)
  end
end
