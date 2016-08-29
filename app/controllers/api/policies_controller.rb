# frozen_string_literal: true
require 'json-schema'

module Api
  class PoliciesController < Api::ServiceController
    before_action :validate_index_request, only: :index

    before_action :parse_and_validate_create_request, only: :create

    before_action :validate_destroy_request, only: :destroy

    def index
      render json: { policies: build_policies(params[:path]) }, status: :ok
    end

    def create
      resource = Resource.find_by(path: @json['path'])

      if resource
        if current_user.owns_resource?(resource)
          merge_policy

          head :ok
        else
          head :forbidden
        end
      else
        Resource.transaction do
          resource = Resource.create(service: service, path: @json['path'])
          create_user_access_policy(current_user, ['manage'], resource)
          if @json['permissions']
            @json['permissions'].each do |permission|
              if permission['type'] == 'user_permission'
                user = User.find_by(email: permission['entity_name'])
                create_user_access_policy(user, permission['access_methods'], resource)
              elsif permission['type'] == 'group_permission'
                group = Group.find_by(name: permission['entity_name'])
                create_group_access_policy(group, permission['access_methods'], resource)
              end
            end
          end

          if @json['managers'] && @json['managers']['users']
            access_method = AccessMethod.find_by(name: 'manage'),
            @json['managers']['users'].each do |email|
              AccessPolicy.create(
                user: User.find_by(email: email),
                access_method: access_method,
                resource: resource
              )
            end
          end

          if @json['managers'] && @json['managers']['groups']
            access_method = AccessMethod.find_by(name: 'manage'),
            @json['managers']['groups'].each do |group_name|
              AccessPolicy.create(
                group: Group.find_by(name: group_name),
                access_method: access_method,
                resource: resource
              )
            end
          end
        end

        head :created
      end
    end

    def destroy
      paths = resource_paths_from_param

      if user_allowed_to_modify_resources?(paths)
        user_emails = user_emails_from_param
        group_names = group_names_from_param
        access_method_names = access_method_names_from_param

        query = AccessPolicy.where(resource: Resource.where(path: paths)).
                             where.not(access_method: AccessMethod.where(name: 'manage'))
        query = query.where(access_method: AccessMethod.where(name: access_method_names)) unless
          access_method_names.empty?
        query = query.where(user: User.where(email: user_emails)) unless user_emails.empty?
        query = query.where(group: Group.where(name: group_names)) unless group_names.empty?
        query.destroy_all

        head :no_content
      else
        head :forbidden
      end
    end

    private

    def validate_index_request
      head :bad_request unless Resource.paths_exist?(resource_paths_from_param)
    end

    def parse_and_validate_create_request
      schema = File.read(File.join(Rails.root, 'config', 'schemas', 'policy-schema.json'))
      @json = JSON.parse(request.body.read)
      head :bad_request unless JSON::Validator.validate(schema, @json)
    end

    def validate_destroy_request
      head :bad_request unless resource_paths_from_param.any? &&
        Resource.paths_exist?(resource_paths_from_param) &&
        User.emails_exist?(user_emails_from_param) &&
        Group.names_exist?(group_names_from_param) &&
        AccessMethod.names_exist?(access_method_names_from_param)
    end

    def create_user_access_policy(user, access_methods, resource)
      access_methods.each do |access_method|
        AccessPolicy.create(
          user: user,
          access_method: AccessMethod.find_by(name: access_method.downcase),
          resource: resource
        )
      end
    end

    def create_group_access_policy(group, access_methods, resource)
      access_methods.each do |access_method|
        AccessPolicy.create(
          group: group,
          access_method: AccessMethod.find_by(name: access_method.downcase),
          resource: resource
        )
      end
    end

    def resource_paths_from_param
      if params[:path]
        params[:path].split(',').map { |param_path| Resource.normalize_path(param_path) }
      else
        []
      end
    end

    def user_emails_from_param
      params[:user] ? params[:user].split(',') : []
    end

    def group_names_from_param
      params[:group] ? params[:group].split(',') : []
    end

    def access_method_names_from_param
      params[:access_method] ? params[:access_method].split(',') : []
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

    def merge_policy
      resource = Resource.find_by(path: @json['path'])

      if @json['managers']
        if @json['managers']['users']
          @json['managers']['users'].each do |email|
            AccessPolicy.find_or_create_by(
              user: User.find_by(email: email),
              access_method: AccessMethod.find_by(name: 'manage'),
              resource: resource
            )
          end
        end

        if @json['managers']['groups']
          @json['managers']['groups'].each do |group_name|
            AccessPolicy.find_or_create_by(
              group: Group.find_by(name: group_name),
              access_method: AccessMethod.find_by(name: 'manage'),
              resource: resource
            )
          end
        end
      end

      if @json['permissions']
        @json['permissions'].each do |permission|
          permission['access_methods'].each do |access_method_name|
            AccessPolicy.find_or_create_by(
              user: User.find_by(email: permission['entity_name']),
              group: Group.find_by(name: permission['entity_name']),
              access_method: AccessMethod.find_by(name: access_method_name),
              resource: resource
            )
          end
        end
      end
    end

    def user_allowed_to_modify_resources?(resource_paths)
      Resource.where(path: resource_paths).map do |resource|
        current_user.owns_resource?(resource)
      end.reduce(:&)
    end
  end
end
