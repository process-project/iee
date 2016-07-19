class AccessPoliciesController < ApplicationController
  def new
    @resource = Resource.find_by(id: params[:resource_id])

    if @resource
      @access_policy = AccessPolicy.new
      set_other_fields
    else
      flash[:alert] = t("resource_not_found")
      redirect_to resources_path
    end
  end

  def create
    @access_policy = AccessPolicy.new(access_policy_params)
    @resource = Resource.find_by(id: @access_policy.resource_id)

    if !@resource
      flash[:alert] = t("resource_not_found")
    end

    set_other_fields

    if @access_policy.save
      redirect_to new_access_policy_path(resource_id: @access_policy.resource_id)
    else
      render :new
    end
  end

  def destroy
    access_policy = AccessPolicy.find_by(id: params[:id])

    if access_policy
      access_policy.destroy
    end

    redirect_to new_access_policy_path(resource_id: params[:resource_id])
  end

  private

  def set_other_fields
    @users = User.approved
    @groups = Group.all
    @access_methods = AccessMethod.all

    @user_access_policies = {}
    User.joins(access_policies: :resource).includes(access_policies: :access_method)
        .where(resources: {id: @resource.id}).each do |user|
      @user_access_policies[user.email] = user.access_policies.where(resource_id: @resource.id)
    end

    @group_access_policies = {}
    Group.joins(access_policies: :resource).includes(access_policies: :access_method)
        .where(resources: {id: @resource.id}).each do |group|
      @group_access_policies[group.name] = group.access_policies.where(resource_id: @resource.id)
    end
  end

  def access_policy_params
    params.require(:access_policy).permit(policy(AccessPolicy).permitted_attributes)
  end
end
