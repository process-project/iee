# frozen_string_literal: true
module Services
  class GlobalPoliciesController < Services::PoliciesController
    before_action :find_and_authorize, only: [:show, :edit, :update, :destroy]

    def index
      @resources = @service.resources.where(resource_type: :global)
    end

    def new
      @resource = Resource.new(service: @service, resource_type: :global)
      authorize(@resource)
    end

    def show
      @model = ResourceAccessPoliciesDecorator.
               new(current_user, @resource, AccessPolicy.new)
    end

    def create
      @resource = Resource.new(permitted_attributes(Resource))
      @resource.service = @service
      @resource.resource_type = :global
      authorize(@resource)

      if @resource.save
        redirect_to(service_global_policy_path(@service, @resource))
      else
        render(:new)
      end
    end

    def edit
    end

    def update
      if @resource.update_attributes(permitted_attributes(@resource))
        redirect_to(service_global_policy_path(@service, @resource))
      else
        render(:edit, status: :bad_request)
      end
    end

    def destroy
      @resource.destroy
      redirect_to(service_global_policies_path(@service))
    end

    private

    def find_and_authorize
      @resource = @service.resources.find(params[:id])
      authorize(@resource)
    end

    def service_finder
      action_name == 'show' ? Service.includes(:access_methods) : Service
    end
  end
end
