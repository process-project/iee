# frozen_string_literal: true
module Resources
  class AccessPoliciesController < ApplicationController
    before_action :find_and_authorize

    def create
      @access_policy = @resource.access_policies.
                       build(permitted_attributes(AccessPolicy))

      @access_policy.save ? redirect_to_list : render_errors
    end

    def destroy
      access_policy = AccessPolicy.find(params[:id])
      access_policy.destroy!

      redirect_to_list
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
               new(current_user, @resource, @access_policy)
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
