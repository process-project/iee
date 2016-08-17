# frozen_string_literal: true
module Api
  class PoliciesController < Api::ServiceController
    before_action :parse_request, only: :create

    before_action only: :create do
      render_bad_request unless json_params_valid?
    end

    def index
      result = { policies: build_policies(params[:path]) }

      render json: result, status: :ok
    end

    def create
      Resource.transaction do
        resource = Resource.create(service: service, path: @json['resource_path'])
        user = User.find_by(email: @json['user'])
        @json['access_methods'].each do |access_method|
          create_access_policy(user, access_method, resource)
        end
      end

      head :created
    end

    def destroy
      resource = Resource.find_by(path: resource_path_param, service: service)

      if resource
        resource.destroy
        head :no_content
      else
        head :not_found
      end
    end

    private

    def parse_request
      @json = JSON.parse(request.body.read)
    end

    def json_params_valid?
      @json.key?('resource_path') && @json.key?('user') && @json.key?('access_methods') &&
        @json['access_methods'].respond_to?(:[]) && User.exists?(email: @json['user']) &&
        @json['access_methods'].map do |access_method|
          AccessMethod.where('lower(name) = ?', access_method.downcase).exists?
        end.reduce(:&)
    end

    def render_bad_request
      head :bad_request
    end

    def create_access_policy(user, access_method, resource)
      AccessPolicy.create(
        user: user,
        access_method: AccessMethod.find_by(name: access_method.downcase),
        resource: resource
      )
    end

    def resource_path_param
      Resource.normalize_path(params[:resource_path]) if params[:resource_path]
    end

    def build_policies(path_param)
      paths = path_param ? path_param.split(',') : []

      fetch_resources(paths).map do |resource|
        { path: resource.path, managers: managers(resource), permissions: permissions(resource) }
      end
    end

    def fetch_resources(paths)
      paths.any? ? Resource.where(path: paths) : Resource.all
    end

    def managers(resource)
      policies = management_access_policies(resource)

      {
        users: policies.select(&:user).map { |policy| policy.user.email },
        groups: policies.select(&:group).map { |policy| policy.group.name }
      }
    end

    def permissions(resource)
      policies = non_management_access_policies(resource)
      user_methods = Hash.new { |h, k| h[k] = [] }
      group_methods = Hash.new { |h, k| h[k] = [] }
      process_policies(policies, user_methods, group_methods)

      build_user_permissions(user_methods) + build_group_permissions(group_methods)
    end

    def management_access_policies(resource)
      AccessPolicy.where(resource: resource, access_method: AccessMethod.where(name: 'manage'))
    end

    def non_management_access_policies(resource)
      AccessPolicy.where(resource: resource).
        where.not(access_method: AccessMethod.where(name: 'manage'))
    end

    def build_user_permissions(user_methods)
      user_methods.map do |user, methods|
        { type: 'user_permission', entity_name:  user, access_methods: methods }
      end
    end

    def build_group_permissions(group_methods)
      group_methods.map do |group, methods|
        { type: 'group_permission', entity_name:  group, access_methods: methods }
      end
    end

    def process_policies(policies, user_methods, group_methods)
      policies.each do |policy|
        if policy.user
          user_methods[policy.user.email] << policy.access_method.name
        else
          group_methods[policy.group.name] << policy.access_method.name
        end
      end
    end
  end
end
