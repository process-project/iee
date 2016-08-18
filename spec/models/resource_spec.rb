# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Resource do
  it { should validate_presence_of(:path) }
  it { should validate_presence_of(:service) }
  it { should have_many(:access_policies).dependent(:destroy) }
  it { should validate_presence_of(:resource_type) }

  it 'checks regular expression match' do
    resource = build(:resource, path: 'path/.*')

    resource.save

    expect(Resource.where(':path ~ path', path: 'path/something')).to exist
  end

  it 'still should pick exact matches correctly' do
    resource = build(:resource, path: 'exact')

    resource.save

    expect(Resource.where(':path ~ path', path: 'exact')).to exist
  end

  it 'concatenate uri basing on service uri and path' do
    service = build(:service, uri: 'https://test')
    r1 = build(:resource, service: service, path: 'my-path')
    r2 = build(:resource, service: service, path: nil)

    expect(r1.uri).to eq('https://test/my-path')
    expect(r2.uri).to eq('https://test/')
  end

  it 'removes / from path start' do
    resource = create(:resource, path: '/my-path')

    expect(resource.path).to eq('my-path')
  end

  it 'should set a default resource type to global' do
    resource = create(:resource)

    expect(resource.resource_type).to eq('global')
    expect(resource.global?).to be(true)
  end

  it 'should not allow for a creation of a local resource which matches another local resource' do
    create(:resource, path: '/path/.*', resource_type: :local)
    another_resource = build(:resource, path: '/path.*')

    expect(another_resource).not_to be_valid
  end
end
