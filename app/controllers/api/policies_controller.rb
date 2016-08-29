# frozen_string_literal: true
require 'json-schema'

module Api
  class PoliciesController < Api::ServiceController
    before_action :validate_index_request, only: :index

    before_action :parse_and_validate_create_request, only: :create

    before_action :validate_destroy_request, only: :destroy

    def index
      render json: Policies::BuildPolicyResponse.new(resource_paths).call, status: :ok
    end

    def create
      resource = Resource.find_by(path: @json['path'])

      if resource
        merge_policy(resource)
      else
        Policies::CreatePolicy.new(@json, service, current_user).call

        head :created
      end
    end

    def destroy
      paths = resource_paths

      if user_allowed_to_modify_resources?(paths)
        Policies::RemovePolicies.new(paths, extract_multiple_param(:user),
                                     extract_multiple_param(:group),
                                     extract_multiple_param(:access_method)).call
        head :no_content
      else
        head :forbidden
      end
    end

    private

    def merge_policy(resource)
      if ResourcePolicy.new(current_user, resource).owns_resource?
        Policies::MergePolicy.new(@json, resource).call

        head :ok
      else
        head :forbidden
      end
    end

    def validate_index_request
      head :bad_request unless Resource.paths_exist?(resource_paths)
    end

    def parse_and_validate_create_request
      schema = File.read(File.join(Rails.root, 'config', 'schemas', 'policy-schema.json'))
      @json = JSON.parse(request.body.read)
      head :bad_request unless JSON::Validator.validate(schema, @json)
    end

    def validate_destroy_request
      head :bad_request unless
        resource_paths.any? &&
        Resource.paths_exist?(resource_paths) &&
        User.emails_exist?(extract_multiple_param(:user)) &&
        Group.names_exist?(extract_multiple_param(:group)) &&
        AccessMethod.names_exist?(extract_multiple_param(:access_method))
    end

    def resource_paths
      Resource.normalize_paths(extract_multiple_param(:path))
    end

    def extract_multiple_param(name)
      params[name] ? params[name].split(',') : []
    end

    def user_allowed_to_modify_resources?(resource_paths)
      Resource.where(path: resource_paths).map do |resource|
        ResourcePolicy.new(current_user, resource).owns_resource?
      end.reduce(:&)
    end
  end
end
