FactoryGirl.define do
  factory :computation do
    script { Faker::Lorem.sentence }
    working_directory { Faker::Lorem.word }

    user
  end
end

