# frozen_string_literal: true
module Services
  class PoliciesController < ApplicationController
    before_action :load_service
    before_action :find_and_authorize, only: [:show, :edit, :update, :destroy]

    def index
      @resources = @service.resources.where(resource_type: resource_type)
    end

    def new
      @resource = Resource.new(service: @service, resource_type: resource_type)
      authorize(@resource)
    end

    def show
      @model = ResourceAccessPoliciesDecorator.
               new(current_user, @resource, AccessPolicy.new)

      @managers_model = ResourceManagersDecorator.
                        new(@resource, ResourceManager.new)
    end

    def create
      @resource = Resource.new(permitted_attributes(Resource))
      @resource.service = @service
      @resource.resource_type = resource_type
      @resource.resource_managers.build(user: current_user)
      authorize(@resource)

      if @resource.save
        redirect_to(resource_path(@service, @resource))
      else
        render(:new)
      end
    end

    def edit; end

    def update
      if @resource.update_attributes(permitted_attributes(@resource))
        redirect_to(resource_path(@service, @resource))
      else
        render(:edit, status: :bad_request)
      end
    end

    def destroy
      @resource.destroy
      redirect_to(resources_path(@service))
    end

    private

    def find_and_authorize
      @resource = @service.resources.
                  find_by!(id: params[:id], resource_type: resource_type)
      authorize(@resource)
    end

    def load_service
      @service = service_finder.find(params[:service_id])
      authorize(@service, :show?)
    end

    def service_finder
      action_name == 'show' ? Service.includes(:access_methods) : Service
    end

    def resource_type
      raise 'Need resource type'
    end

    def resource_path(_service, _resource)
      raise 'Need resource path'
    end

    def resources_path(_service)
      raise 'Need resource path'
    end
  end
end
