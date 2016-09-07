# frozen_string_literal: true
class ResourcesController < ApplicationController
  def index
    @resources = policy_scope(Resource).order(:name)
  end

  def new
    @services = current_user.services
  end

  def create
    @resource = Resource.new(resource_params)
    authorize(@resource.service, :update?)

    @resource.transaction do
      if @resource.save
        @resource.access_policies.create!(user: current_user, resource: @resource,
                                          access_method: AccessMethod.find_by(name: 'manage'))
      end
    end

    render_created_resource(@resource)
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

  def render_created_resource(resource)
    if resource.new_record?
      @services = current_user.services
      render(:new)
    else
      redirect_to(resources_path)
    end
  end

  def resource_params
    params.require(:resource).permit(policy(view_context.resource).permitted_attributes).
      merge(resource_type: :global)
  end
end
