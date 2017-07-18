# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Service do
  subject { build(:service) }

  it { should validate_presence_of(:uri) }
  it { should validate_uniqueness_of(:uri) }

  it 'auto-validate built service' do
    build(:service).valid?
  end

  # NOTE: default uniqueness test seams to not work properly for PSQL Tables
  it 'validates uri_aliases uniqueness' do
    s1 = create(:service)
    service = build(:service, uri_aliases: s1.uri_aliases)

    expect(service).to_not be_valid
  end

  it 'doesn\'t allow to add service with URI already defined as alias' do
    s1 = create(:service)
    service = build(:service, uri: s1.uri_aliases.first)

    expect(service).to_not be_valid
  end

  it 'doesn\'t allow to add service with alias already defined as URI' do
    s1 = create(:service)
    service = build(:service, uri_aliases: [s1.uri])

    expect(service).to_not be_valid
  end

  it 'doesn\'t allow to add service with same URI and alias' do
    service = build(:service, uri: 'https://my.service.pl', uri_aliases: ['https://my.service.pl'])

    expect(service).to_not be_valid
  end

  it 'doesn\'t allow to add service with URI equal to one of the alias' do
    service = build(:service)
    service.uri = service.uri_aliases.first

    expect(service).to_not be_valid
  end

  it { should have_many(:resources).dependent(:destroy) }
  it { should have_many(:service_ownerships).dependent(:destroy) }

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

  it 'doesn\'t allow to create second service with lower uri' do
    create(:service, uri: 'https://my.service.pl/my/service')
    service = build(:service, uri: 'https://my.service.pl/my/service/1')

    expect(service).to_not be_valid
  end

  # Intentionally used similar URI to test false positives on lower uri test
  it 'allow to create second service with equal-level uri' do
    create(:service, uri: 'https://my.service.pl/my/service')
    service = build(:service, uri: 'https://my.service.pl/my/service1')

    expect(service).to be_valid
  end

  it 'allow to create second service with longer TLD' do
    create(:service, uri: 'https://my.service.co')
    service = build(:service, uri: 'https://my.service.com')

    expect(service).to be_valid
  end

  it 'allow to create second service with shorter TLD' do
    create(:service, uri: 'https://my.service.com')
    service = build(:service, uri: 'https://my.service.co')

    expect(service).to be_valid
  end

  it 'doesn\'t allow to create second service with higher uri as alias' do
    create(:service, uri: 'https://my.service.pl/my/service')
    service = build(:service, uri_aliases: ['https://my.service.pl'])

    expect(service).to_not be_valid
  end

  it 'doesn\'t allow to create second service with higher uri_alias' do
    create(:service, uri_aliases: ['https://my.service.pl/my/service'])
    service = build(:service, uri: 'https://my.service.pl')

    expect(service).to_not be_valid
  end

  it 'doesn\'t allow to create second service with lower uri as alias' do
    create(:service, uri: 'https://my.service.pl/my/service')
    service = build(:service, uri_aliases: ['https://my.service.pl/my/service/1'])

    expect(service).to_not be_valid
  end

  it 'doesn\'t allow to create second service with lower uri_alias' do
    create(:service, uri_aliases: ['https://my.service.pl/my/service'])
    service = build(:service, uri: 'https://my.service.pl/my/service/1')

    expect(service).to_not be_valid
  end

  it 'allow to create second service with equal uri as alias' do
    create(:service, uri: 'https://my.service.pl/1')
    service = build(:service, uri_aliases: ['https://my.service.pl/2'])

    expect(service).to be_valid
  end

  it 'allow to create second service with equal uri_alias' do
    create(:service, uri_aliases: ['https://my.service.pl/1'])
    service = build(:service, uri: 'https://my.service.pl/2')

    expect(service).to be_valid
  end

  it 'allow to create second service with longer TLD as alias' do
    create(:service, uri: 'https://my.service.co')
    service = build(:service, uri_aliases: ['https://my.service.com'])

    expect(service).to be_valid
  end

  it 'allow to create second service with longer TLD in uri_alias' do
    create(:service, uri_aliases: ['https://my.service.co'])
    service = build(:service, uri: 'https://my.service.com')

    expect(service).to be_valid
  end

  it 'allow to create second service with shorter TLD as alias' do
    create(:service, uri: 'https://my.service.com')
    service = build(:service, uri_aliases: ['https://my.service.co'])

    expect(service).to be_valid
  end

  it 'allow to create second service with shorter TLD in uri_alias' do
    create(:service, uri_aliases: ['https://my.service.com'])
    service = build(:service, uri: 'https://my.service.co')

    expect(service).to be_valid
  end

  it 'allows to update a service without failing URI validation' do
    expect { create(:service).save! }.not_to raise_error
  end

  context 'service uri ends with slash' do
    let(:slash_service) { build(:service, uri: 'http://host.pl/') }
    it 'is invalid' do
      expect(slash_service).to_not be_valid
    end

    it 'has a proper error message' do
      slash_service.save
      expect(slash_service.errors.messages).to eq(uri: ['Service URI cannot end with a slash'])
    end
  end
end
