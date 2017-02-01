# frozen_string_literal: true
require 'rails_helper'

describe ValidateProxy do
  include ProxySpecHelper
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user, proxy: outdated_proxy) }

  subject { ValidateProxy.new(user) }

  context 'valid proxy' do
    before(:context) { travel_to valid_proxy_time }
    after(:context) { travel_back }

    it 'invoke block when proxy is valid' do
      expect { |b| subject.call(&b) }.to yield_control
    end

    it 'does not send any emails' do
      expect { subject.call }.to_not change { ActionMailer::Base.deliveries.count }
    end
  end

  context 'invalid proxy' do
    it 'does not invoke block when proxy is not valid' do
      expect { |b| subject.call(&b) }.to_not yield_control
    end

    it 'sends email to the user about proxy expiration' do
      expect { subject.call }.
        to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'sends 1 email every day about proxy expiration' do
      expect do
        subject.call
        subject.call

        travel 25.hours
        subject.call
      end.to change { ActionMailer::Base.deliveries.count }.by(2)
    end
  end
end
