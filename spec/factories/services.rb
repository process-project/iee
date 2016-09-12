# frozen_string_literal: true
FactoryGirl.define do
  factory :service do
    uri do
      uri = URI.parse(Faker::Internet.url)
      "#{uri.scheme}://#{uri.host}"
    end

    before :create do |service|
      service.users << create(:user) unless service.users.present?
    end
  end
end
