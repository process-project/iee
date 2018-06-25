# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Audits::PerformJob, type: :job do
  it 'runs audit verification service' do
    user = build(:user)
    perform = instance_double(Audits::Perform)

    expect(perform).to receive(:call)
    allow(Audits::Perform).
       to receive(:new).with(user).and_return(perform)

    described_class.perform_now(user)
  end
end
