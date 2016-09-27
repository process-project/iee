# frozen_string_literal: true
module Resources
  class AccessPoliciesController < ApplicationController
    before_action :find_and_authorize

    def create
      @access_policy = AccessPolicy.new(permitted_attributes(AccessPolicy))
      @access_policy.resource = @resource

      if @access_policy.save
        redirect_to service_global_policy_path(@resource.service, @resource)
      else
        @model = ResourceAccessPoliciesDecorator.
                 new(@resource, @access_policy)
        @service = @resource.service
        render('services/global_policies/show', status: :bad_request)
      end
    end

    def destroy
      access_policy = AccessPolicy.find(params[:id])
      access_policy.destroy!

      redirect_to service_global_policy_path(@resource.service, @resource)
    end

    private

    def find_and_authorize
      @resource = Resource.find(params[:resource_id])
      authorize(@resource, :update?)
    end
  end
end
