# frozen_string_literal: true
module Policies
  class CopyPolicy < Policies::BasePoliciesService
    def initialize(copy_from, copy_to, service, user)
      super(service)
      @copy_from = copy_from
      @copy_to = copy_to
      @user = user
    end

    def call
      Resource.transaction do
        find_subresources(@copy_from).each do |source_resource|
          target_resource = duplicate(source_resource)
          copy_managers(source_resource, target_resource)
          copy_policies(source_resource, target_resource)
        end
      end
    end

    private

    def duplicate(source_resource)
      target_resource = source_resource.dup
      target_resource.pretty_path = @copy_to + sub_path(@copy_from, source_resource.pretty_path)
      target_resource.save

      target_resource
    end
  end
end
