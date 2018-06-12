FactoryBot.define do
  factory :ip do
    address { Faker::Internet.public_ip_v4_address }

    user
  end
end
