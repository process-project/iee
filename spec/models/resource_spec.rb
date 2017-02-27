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

  context 'with path edited via the pretty_path accessor' do
    it 'should accept a pretty path without an asterisk character' do
      resource = build(:resource, pretty_path: '/any_path/')

      expect(resource).to be_valid
    end

    it 'should accept a pretty path with an asterisk character at the end' do
      resource = build(:resource, pretty_path: '/any_path/*')

      expect(resource).to be_valid
    end

    it 'should not accept a pretty path with an asterisk in the middle' do
      resource = build(:resource, pretty_path: '/any_path*/')

      expect(resource).not_to be_valid
    end

    it 'should transform pretty_path with an asterisk at the end to a regular expression' do
      resource = build(:resource, pretty_path: '/any_path/*')

      expect(resource.path).to eq('/any_path/.*')
    end

    it 'should transform a path with a wildcard expression at the end to an asterisk character' do
      resource = build(:resource, path: '/any_path/.*')

      expect(resource.pretty_path).to eq('/any_path/*')
    end

    it 'should contain a proper error message' do
      resource = build(:resource, pretty_path: '/any_path*/')
      resource.save

      expect(resource.errors.messages).to eq(
        pretty_path: ['Path may contain a single wildcard character at the end'])
    end
  end
end
