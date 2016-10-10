# frozen_string_literal: true
module FactoryGirl
  module ServiceHelper
    class << self
      def uniq_uri(*exclude_uris)
        used_uris = already_used_uris + exclude_uris
        loop do
          uri = URI.parse(Faker::Internet.url)
          candidate_uri = "#{uri.scheme}://#{uri.host}"
          break candidate_uri unless used_uris.include? candidate_uri
        end
      end

      private

      def already_used_uris
        Service.all.collect { |s| s.uri_aliases << s.uri }.flatten
      end
    end
  end
end
