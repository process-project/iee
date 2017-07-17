# frozen_string_literal: true

module Policies
  class MovePolicy < Policies::BasePoliciesService
    def initialize(move_from, move_to, service, user)
      super(service)
      @move_from = move_from
      @move_to = move_to
      @user = user
    end

    def call
      Resource.transaction do
        find_subresources(@move_from).each do |source_resource|
          source_resource.pretty_path = @move_to + sub_path(@move_from, source_resource.pretty_path)
          source_resource.save!
        end
      end
    end
  end
end
