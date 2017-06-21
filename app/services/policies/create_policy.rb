# frozen_string_literal: true
module Policies
  class CreatePolicy < Policies::BasePoliciesService
    def initialize(json_body, service, user)
      super(service)
      @json_body = json_body
      @user = user
    end

    def call
      Resource.transaction do
        resource = Resource.create!(service: @service,
                                   pretty_path: @json_body['path'],
                                   resource_type: :local)
        create_access_policies(resource)
        create_user_managers(resource)
        create_group_managers(resource)
      end
    end

    private

    def create_access_policies(resource)
      return unless @json_body['permissions']
      @json_body['permissions'].each do |permission|
        process_permission(permission, resource)
      end
    end

    def create_user_managers(resource)
      resource.resource_managers.find_or_create_by(user: @user)

      return unless @json_body['managers'] && @json_body['managers']['users']
      merge_user_managers(@json_body['managers']['users'], resource)
    end

    def create_group_managers(resource)
      return unless @json_body['managers'] && @json_body['managers']['groups']
      merge_group_managers(@json_body['managers']['groups'], resource)
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
