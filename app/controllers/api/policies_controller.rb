# frozen_string_literal: true
require 'json-schema'

module Api
  class PoliciesController < Api::ServiceController
    before_action :validate_index_request, only: :index

    before_action :parse_and_validate_create_request, only: :create
    before_action :check_existence, only: :create
    before_action :check_source, only: :create
    before_action :authorize_copy_move, only: :create, if: :copy_or_move_request?

    before_action :validate_destroy_request, only: :destroy

    def index
      render json: Policies::BuildPolicyResponse.new(resource_paths, service).call, status: :ok
    end

    def create
      if @resource
        merge_policy
      elsif copy_or_move_request?
        process_copy_move_request
      else
        process_create_request
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

    def merge_policy
      if ResourcePolicy.new(current_user, @resource).owns_resource?
        Policies::MergePolicy.new(@json, @resource, service).call

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

    def check_existence
      @resource = service.resources.find_by(path: PathService.to_path(@json['path']))
      return unless @resource && copy_or_move_request?
      api_error(status: :bad_request, errors: I18n.t('api.destination_resource_exists'))
    end

    def check_source
      return unless copy_move_path && !Resource.find_by(path: PathService.to_path(copy_move_path))
      api_error(status: :not_found, errors: I18n.t('api.source_policy_missing'))
    end

    def authorize_copy_move
      authorize(Resource.find_by(path: PathService.to_path(copy_move_path)), :copy_move?)
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

    def process_copy_move_request
      if @json['copy_from']
        Policies::CopyPolicy.new(@json['copy_from'], @json['path'], service, current_user).call
      else
        Policies::MovePolicy.new(@json['move_from'], @json['path'], service, current_user).call
      end

      head :created
    end

    def process_create_request
      Policies::CreatePolicy.new(@json, service, current_user).call

      head :created
    end
  end
end
