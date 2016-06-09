FactoryGirl.define do
  factory :resource do
    name { Faker::Name.name }
    path { Faker::Internet.domain_word }
    service
  end
end
