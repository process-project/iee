# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Service do
  subject { build(:service) }

  it { should validate_presence_of(:uri) }
  it { should validate_uniqueness_of(:uri) }
  it { should validate_uniqueness_of(:uri_aliases) }

  it { should have_many(:resources).dependent(:destroy) }

  it 'creates unique token' do
    expect(create(:service).token).to_not be_nil
  end

  it 'validates correct uri format' do
    service = build(:service, uri: 'wrong$%^uri')

    expect(service).to_not be_valid
  end

  it 'validates correct uri_aliases format' do
    service = build(:service, uri_aliases: ['wrong$%^uri'])

    expect(service).to_not be_valid
  end

  it 'doesn\'t allow to create second service with higher uri' do
    create(:service, uri: 'https://my.service.pl/my/service')
    service = build(:service, uri: 'https://my.service.pl')

    expect(service).to_not be_valid
  end

  it 'allows to update a service without failing URI validation' do
    expect { create(:service).save! }.not_to raise_error
  end
end
