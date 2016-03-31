require 'rails_helper'

RSpec.describe Permission do
  it { should belong_to(:user) }
  it { should belong_to(:group) }
  it { should belong_to(:action) }
  it { should belong_to(:resource) }

  context 'if no user' do
    before { allow(subject).to receive(:user).and_return(nil) }
    it { should validate_presence_of(:group) }
  end

  context 'if no group' do
    before { allow(subject).to receive(:group).and_return(nil) }
    it { should validate_presence_of(:user) }
  end
end
