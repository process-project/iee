# frozen_string_literal: true
module Policies
  class CreatePolicy
    def initialize(json_body, service, user)
      @json_body = json_body
      @service = service
      @user = user
    end

    def call
      Resource.transaction do
        resource = Resource.create(service: @service, path: @json_body['path'])
        safely_create_access_policy(@user, nil, ['manage'], resource)
        create_access_policies(resource)
        create_user_managers(resource)
        create_group_managers(resource)
      end
    end

    private

    def safely_create_access_policy(user, group, access_methods, resource)
      access_methods.each do |access_method|
        AccessPolicy.find_or_create_by(
          user: user,
          group: group,
          access_method: AccessMethod.find_by(name: access_method.downcase),
          resource: resource
        )
      end
    end

    def create_access_policies(resource)
      if @json_body['permissions']
        @json_body['permissions'].each do |permission|
          process_permission(permission, resource)
        end
      end
    end

    def create_user_managers(resource)
      if @json_body['managers'] && @json_body['managers']['users']
        @json_body['managers']['users'].each do |email|
          safely_create_access_policy(User.find_by(email: email), nil, ['manage'], resource)
        end
      end
    end

    def create_group_managers(resource)
      if @json_body['managers'] && @json_body['managers']['groups']
        @json_body['managers']['groups'].each do |group_name|
          safely_create_access_policy(nil, Group.find_by(name: group_name), nil, ['manage'],
                                      resource)
        end
      end
    end

    def process_permission(permission, resource)
      if permission['type'] == 'user_permission'
        user = User.find_by(email: permission['entity_name'])
        safely_create_access_policy(user, nil, permission['access_methods'], resource)
      elsif permission['type'] == 'group_permission'
        group = Group.find_by(name: permission['entity_name'])
        safely_create_access_policy(nil, group, permission['access_methods'], resource)
      end
    end
  end
end
