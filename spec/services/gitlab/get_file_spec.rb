# frozen_string_literal: true

require 'rails_helper'

describe Gitlab::Versions do
  it 'downloads files from gitlab', gitlab: true do
    content = Gitlab::GetFile.new('eurvalve/integration-testing', 'README.md', 'some_branch').call

    expect(content).to be_instance_of(String)
    expect(content).to include 'Prometheus'
  end
end
