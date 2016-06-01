require 'rails_helper'

RSpec.describe Resource do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:uri) }
  it { should have_many(:permissions).dependent(:destroy) }
  
  it "checks regular expression match" do
    resource = build(:resource, uri: "http://host/.*")
    
    resource.save
    
    expect(Resource.where(":uri ~ uri", uri: "http://host/something").count).
      to equal(1)
  end
  
  it "still should pick exact matches correctly" do
    resource = build(:resource, uri: "http://host/exact")
    
    resource.save
    
    expect(Resource.where(":uri ~ uri", uri: "http://host/exact").count).
      to equal(1)
  end
end
