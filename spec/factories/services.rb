# frozen_string_literal: true
FactoryGirl.define do
  factory :service do
    uri do
      uri = URI.parse(Faker::Internet.url)
      "#{uri.scheme}://#{uri.host}"
    end

    uri_aliases do
      uri_alias1 = URI.parse(Faker::Internet.url)
      uri_alias2 = URI.parse(Faker::Internet.url)
      %W(#{uri_alias1.scheme}://#{uri_alias1.host} #{uri_alias2.scheme}://#{uri_alias2.host})
    end

    before :create do |service|
      service.users << create(:user) unless service.users.present?
    end
  end
end
