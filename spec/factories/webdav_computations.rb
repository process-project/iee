# frozen_string_literal: true

FactoryGirl.define do
  factory :webdav_computation do
    input_path { '/inputs' }
    output_path { '/outputs' }
  end
end
