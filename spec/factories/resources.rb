FactoryGirl.define do
  factory :resource do
    name { Faker::Name.name }
    uri { Faker::Internet.url }
  end
end
