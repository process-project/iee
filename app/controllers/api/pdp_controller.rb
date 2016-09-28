# frozen_string_literal: true
module Api
  class PdpController < Api::ApplicationController
    def index
      head(permit? ? :ok : :forbidden)
    end

    private

    # policies of all matching resources which include the access method in question
    # must allow for access and at least one policy has to exist
    def permit?
      return false if access_method.blank? || uri.blank? || service.nil?

      resources = service.resources.
                  joins(access_policies: :access_method).
                  where(':path ~ path', path: path).
                  where(access_methods: { name: access_method })
      every_resource_permitted?(resources)
    end

    def path
      postfix = uri
      postfix[(service.uri.length + 1)..-1]
    end

    def service
      @service ||= find_service
    end

    def find_service
      Service.find_each do |service|
        return service if ([service.uri] + service.uri_aliases).any? { |u| uri.starts_with?(u) }
      end
    end

    def every_resource_permitted?(resources)
      resources.map { |r| policy(r).permit?(access_method) }.reduce(:&)
    end

    def uri
      params[:uri]
    end

    def access_method
      params[:access_method]&.downcase
    end
  end
end
