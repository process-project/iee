# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ProxyHelper do
  include ProxySpecHelper

  let(:current_user) { build(:user) }

  describe `#require_new_proxy?` do
    it 'is true when active computation and proxy is empty' do
      create(:computation, status: 'new', user: current_user)
      current_user.proxy = nil

      expect(require_new_proxy?).to be_truthy
    end

    it 'is true when active computation and proxy is outdated' do
      create(:computation, status: 'new', user: current_user)
      current_user.proxy = outdated_proxy

      expect(require_new_proxy?).to be_truthy
    end

    it 'is false when no active computation and proxy is empty' do
      current_user.proxy = nil

      expect(require_new_proxy?).to be_falsy
    end
  end
end
