# frozen_string_literal: true
module Policies
  class CopyMovePolicy < Policies::BasePoliciesService
    def initialize(json_body, service, user)
      super(service)
      @json_body = json_body
      @user = user
    end

    def call
      if @json_body['copy_from']
        copy_policy
      else
        move_policy
      end
    end

    private

    def copy_policy
      Resource.transaction do
        find_subresources(@json_body['copy_from']).each do |source_resource|
          target_resource = source_resource.dup
          target_resource.path = @json_body['path'] + sub_path(@json_body['copy_from'], source_resource.path)
          target_resource.save
          source_resource.resource_managers.each do |manager|
            target_resource.resource_managers  << manager.dup
          end
          source_resource.access_policies.each do |access_policy|
            target_resource.access_policies << access_policy.dup
          end
        end
      end
    end

    def move_policy
      Resource.transaction do
        find_subresources(@json_body['move_from']).each do |source_resource|
          source_resource.path = @json_body['path'] + sub_path(@json_body['move_from'], source_resource.path)
          source_resource.save
        end
      end
    end

    def find_subresources(pretty_path)
      Resource.where('path like :prefix', prefix: "#{PathService.to_path(pretty_path)}%")
    end

    def sub_path(root_path, sub_path)
      sub_path[root_path.length..-1]
    end
  end
end
