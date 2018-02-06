FactoryBot.define do
  factory :user_audit do
    ip { Faker::Internet.public_ip_v4_address }
    user_agent { Faker::Internet.user_agent }
    accept_language do
      c = Faker::Lorem.characters(2)
      "#{c.downcase}-#{c},#{c.downcase};q=0.#{Faker::Number.between(1,9)}"
    end

    user
  end
end
