require 'rails_helper'

RSpec.describe Rimrock::StartJob do
  it 'triggers user computations update' do
    user = 'user'
    start = instance_double(Rimrock::Start)

    expect(start).to receive(:call)
    allow(Rimrock::Start).to receive(:new).with(user).and_return(start)

    described_class.perform_now(user)
  end
end

