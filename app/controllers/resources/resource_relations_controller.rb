# frozen_string_literal: true
module Resources
  class ResourceRelationsController < ApplicationController
    before_action :find_and_authorize

    def create
      @related_object = build_related_object

      @related_object.save ? redirect_to_list : render_errors
    end

    def destroy
      find_related_object.destroy!

      redirect_to_list
    end

    protected

    def build_relatd_object
      raise 'Need to be implemented'
    end

    def find_relatd_object
      raise 'Need to be implemented'
    end

    def access_policy
      raise 'Need to be implemented'
    end

    def resource_manager
      raise 'Need to be implemented'
    end

    private

    def redirect_to_list
      if @resource.global?
        redirect_to service_global_policy_path(@resource.service, @resource)
      else
        redirect_to service_local_policy_path(@resource.service, @resource)
      end
    end

    def render_errors
      @model = ResourceAccessPoliciesDecorator.
               new(current_user, @resource, access_policy)
      @managers_model = ResourceManagersDecorator.
                        new(@resource, resource_manager)

      @service = @resource.service

      render("services/#{@resource.resource_type}_policies/show",
             status: :bad_request)
    end

    def find_and_authorize
      @resource = Resource.find(params[:resource_id])
      authorize(@resource, :update?)
    end
  end
end
