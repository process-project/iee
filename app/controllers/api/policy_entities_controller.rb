# frozen_string_literal: true

module Api
  class PolicyEntitiesController < Api::ServiceController
    def index
      result = {
        policy_entities: user_entities + group_entities + access_method_entities
      }

      render json: result, status: :ok
    end

    private

    def user_entities
      User.approved.map { |user| { type: :user_entity, name: user.email } }
    end

    def group_entities
      Group.all.map { |group| { type: :group_entity, name: group.name } }
    end

    def access_method_entities
      AccessMethod.all.map do |access_method|
        { type: :access_method_entity, name: access_method.name }
      end
    end
  end
end
