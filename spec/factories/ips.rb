FactoryBot.define do
  factory :ip do
    name { Faker::Internet.public_ip_v4_address }

    user
  end
end
