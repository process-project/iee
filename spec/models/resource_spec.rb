# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Resource do
  it { should validate_presence_of(:path) }
  it { should validate_presence_of(:service) }
  it { should have_many(:access_policies).dependent(:destroy) }
  it { should validate_presence_of(:resource_type) }

  context 'path does not start with a slash' do
    let(:resource) { build(:resource, path: 'path') }
    it 'is invalid' do
      expect(resource).to_not be_valid
    end

    it 'has a proper error message' do
      resource.save
      expect(resource.errors.messages).to eq(path: ['Resource path must start with a slash'])
    end
  end

  it 'checks regular expression match' do
    resource = build(:resource, path: '/path/.*')

    resource.save

    expect(Resource.where(':path ~ path', path: '/path/something')).to exist
  end

  it 'still should pick exact matches correctly' do
    resource = build(:resource, path: '/exact')

    resource.save

    expect(Resource.where(':path ~ path', path: '/exact')).to exist
  end

  it 'concatenate uri basing on service uri and path' do
    service = build(:service, uri: 'https://test')
    r1 = build(:resource, service: service, path: '/my-path')

    expect(r1.uri).to eq('https://test/my-path')
  end

  context 'path present in service uri' do
    it 'concatenates uri correctly' do
      service_with_path = build(:service, uri: 'https://test/service')
      r1 = build(:resource, service: service_with_path, path: '/resource')

    expect(r1.uri).to eq('https://test/service/resource')
    end
  end

  it 'should not allow for a creation of a local resource which matches another local resource' do
    create(:resource, path: '/path/.*', resource_type: :local)
    another_resource = build(:resource, path: '/path.*')

    expect(another_resource).not_to be_valid
  end
end
