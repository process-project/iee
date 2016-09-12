# frozen_string_literal: true
module Api
  class PdpController < Api::ApplicationController
    def index
      head(permit? ? :ok : :forbidden)
    end

    private

    # policies of all matching resources must allow for access and at least one policy has to exist
    def permit?
      resources = service&.resources&.where(':path ~ path', path: path)
      every_resource_permitted? resources
    end

    def path
      postfix = uri
      postfix[(service.uri.length + 1)..-1]
    end

    def service
      Service.find_each do |service|
        return service if ([service.uri] + service.uri_aliases).any? { |u| uri.starts_with?(u) }
      end
    end

    def every_resource_permitted?(resources)
      resources&.map { |r| policy(r).permit?(params[:access_method]) }&.reduce(:&)
    end

    def uri
      params[:uri]
    end
  end
end
