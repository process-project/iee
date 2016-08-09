# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ServiceOwnership do
  subject { create(:service_ownership) }

  it { should validate_presence_of(:service) }
  it { should validate_presence_of(:user) }

  it 'prevents duplicated ownership records through validation' do
    duplicated = subject.dup
    expect(ServiceOwnership.count).to eq 1
    expect(duplicated.valid?).to be_falsey
    expect(duplicated.errors[:service]).to include 'has already been taken'
  end

  it 'prevents duplicated ownership records through DB index' do
    duplicated = subject.dup
    expect { duplicated.save(validate: false) }.
      to raise_error ActiveRecord::RecordNotUnique
  end
end
