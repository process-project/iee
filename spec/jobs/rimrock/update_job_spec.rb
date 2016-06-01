require 'rails_helper'

RSpec.describe Rimrock::UpdateJob do
  it 'triggers user computations update' do
    user = 'user'
    update = instance_double(Rimrock::Update)

    expect(update).to receive(:call)
    allow(Rimrock::Update).
      to receive(:new).
      with(user, on_finish_callback: Rimrock::UpdateJob::Updater).
      and_return(update)

    described_class.perform_now(user)
  end
end
