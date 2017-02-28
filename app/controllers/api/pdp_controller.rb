# frozen_string_literal: true
module Api
  class PdpController < Api::ApplicationController
    before_action :setup_service_and_service_uri

    def index
      head(permit? ? :ok : :forbidden)
    end

    private

    attr_reader :service, :service_uri

    # policies of all matching resources which include the access method in question
    # must allow for access and at least one policy has to exist
    def permit?
      return false if access_method.blank? || uri.blank? || service.nil?

      resources = service.resources.
                  joins(access_policies: :access_method).
                  where(':path ~* CONCAT(path, \'$\')', path: path).
                  where(access_methods: { name: access_method })

      every_resource_permitted?(resources)
    end

    def setup_service_and_service_uri
      return if uri.blank?

      service_and_path = find_service_and_path
      @service = service_and_path[:service]
      @service_uri = service_and_path[:service_uri]
    end

    def find_service_and_path
      Service.find_each do |service|
        service_uri = ([service.uri] + service.uri_aliases).
                      find { |u| uri.downcase.starts_with?(u.downcase) }

        return { service: service, service_uri: service_uri } if service_uri
      end
      {}
    end

    def path
      postfix = uri
      path = postfix[(@service_uri.length)..-1]

      path.blank? ? '/' : path
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
