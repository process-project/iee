# frozen_string_literal: true
class ResourcesController < ApplicationController
  def index
    @resources = policy_scope(Resource).order(:name)
  end

  def new
    @services = Service.all
  end

  def create
    @resource = Resource.new(resource_params)

    @resource.transaction do
      if @resource.save
        @resource.access_policies.create!(user: current_user, resource: @resource,
                                          access_method: AccessMethod.find_by(name: 'manage'))
      end
    end

    @resource.new_record? ? render(:new) : redirect_to(resources_path)
  end

  def destroy
    resource = Resource.find(params[:id])

    if resource
      authorize(resource)
      resource.destroy
    end

    redirect_to resources_path
  end

  private

  def resource_params
    params.require(:resource).permit(policy(view_context.resource).permitted_attributes)
  end
end
