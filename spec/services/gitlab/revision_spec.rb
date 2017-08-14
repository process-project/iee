# frozen_string_literal: true

require 'rails_helper'

describe Gitlab::Revision, gitlab: true do
  it 'fetch branch revision' do
    expect(described_class.new('eurvalve/integration-testing', 'master').call).
      to eq 'abec54e5ceb0afae35df762666d50d97f04e235d'
  end

  it 'fetch tag revision' do
    expect(described_class.new('eurvalve/integration-testing', 'some_tag').call).
      to eq 'd8a362a70683fc3a718fbd71c596f2dd8f53c198'
  end

  it 'return nil for non existing tag or version' do
    expect(described_class.new('eurvalve/integration-testing', 'notfound').call).
      to be_nil
  end
end
