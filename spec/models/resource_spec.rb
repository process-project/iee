require 'rails_helper'

RSpec.describe Resource do
  it { should validate_presence_of(:path) }
  it { should have_many(:access_policies).dependent(:destroy) }

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

  it 'contatenate uri basing on service uri and path' do
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
end
