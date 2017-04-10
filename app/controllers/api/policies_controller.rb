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
      resource = Resource.find_by(path: PathService.to_path(@json['path']))

      if resource
        if copy_or_move_request?
          api_error(status: :bad_request)
        else
          merge_policy(resource)
        end
      else
        if copy_or_move_request?
          if ResourcePolicy.user_owns_resources?(current_user, subresource_paths(PathService.to_path(copy_move_path)))
            Policies::CopyMovePolicy.new(@json, service, current_user).call

            head :created
          else
            api_error(status: :forbidden)
          end
        else
          Policies::CreatePolicy.new(@json, service, current_user).call

          head :created
        end
      end
    end

    def destroy
      paths = resource_paths

      if ResourcePolicy.user_owns_resources?(current_user, paths)
        Policies::RemovePolicies.new(paths, extract_multiple_param(:user),
                                     extract_multiple_param(:group),
                                     extract_multiple_param(:access_method)).call
        head :no_content
      else
        api_error(status: :forbidden)
      end
    end

    private

    def merge_policy(resource)
      if ResourcePolicy.new(current_user, resource).owns_resource?
        Policies::MergePolicy.new(@json, resource, service).call

        head :ok
      else
        api_error(status: :forbidden)
      end
    end

    def validate_index_request
      api_error(status: :bad_request) unless Resource.exists_for_attribute?('path', resource_paths)
    end

    def parse_and_validate_create_request
      schema = File.read(Rails.root.join('config', 'schemas', 'policy-schema.json'))
      @json = JSON.parse(request.body.read)
      api_error(status: :bad_request) unless JSON::Validator.validate(schema, @json)
    end

    def validate_destroy_request
      api_error(status: :bad_request) unless
        resource_paths.any? &&
        Resource.exists_for_attribute?('path', resource_paths) &&
        User.exists_for_attribute?('email', extract_multiple_param(:user)) &&
        Group.exists_for_attribute?('name', extract_multiple_param(:group)) &&
        AccessMethod.exists_for_attribute?('name', extract_multiple_param(:access_method))
    end

    def resource_paths
      extract_multiple_param(:path).map { |path| PathService.to_path(path) }
    end

    def extract_multiple_param(name)
      params[name] ? params[name].split(',') : []
    end

    def copy_or_move_request?
      @json['copy_from'] || @json['move_from']
    end

    def copy_move_path
      @json['copy_from'].presence || @json['move_from']
    end

    def subresource_paths(path)
      Resource.where('path like :prefix', prefix: "^#{path}%").map do |resource|
        resource.path
      end
    end
  end
end
