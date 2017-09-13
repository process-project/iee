# frozen_string_literal: true

require 'rails_helper'

describe Gitlab::Versions do
  include ActiveSupport::Testing::TimeHelpers
  Response = Struct.new(:name)

  before { Rails.cache.clear }

  let(:project) { 'eurvalve/integration-testing' }

  it 'downloads branches and tags from gitlab', gitlab: true do
    branches_and_tags = Gitlab::Versions.new(project).call

    expect(branches_and_tags[:branches]).to contain_exactly 'some_branch', 'master'
    expect(branches_and_tags[:tags]).to eq ['some_tag']
  end

  it 'returns empty list of branches and tags for nonexistent repository', gitlab: true do
    Gitlab.configure do |config|
      config.endpoint = 'http://no.such.url.com/api/v4'
    end

    branches_and_tags = Gitlab::Versions.new(project).call
    expect(branches_and_tags[:branches]).to eq []
    expect(branches_and_tags[:tags]).to eq []
  end

  it 'returns empty list of branches and tags on token validation failure', gitlab: true do
    Gitlab.configure do |config|
      config.private_token = 'foo'
    end

    branches_and_tags = Gitlab::Versions.new(project).call
    expect(branches_and_tags[:branches]).to eq []
    expect(branches_and_tags[:tags]).to eq []
  end

  context 'cache' do
    let(:gitlab_client) { double('gitlab client') }

    it 'returns cached tags and versions' do
      expect(gitlab_client).to receive(:branches).and_return([Response.new('b1')]).once
      expect(gitlab_client).to receive(:tags).and_return([Response.new('t1')]).once

      Gitlab::Versions.new('foo/bar', gitlab_client: gitlab_client).call
      Gitlab::Versions.new('foo/bar', gitlab_client: gitlab_client).call
    end

    it 'asks gitlab about versions after cache timeout' do
      expect(gitlab_client).to receive(:branches).and_return([Response.new('b1')]).twice
      expect(gitlab_client).to receive(:tags).and_return([Response.new('t1')]).twice

      Gitlab::Versions.new('foo/bar', gitlab_client: gitlab_client).call

      travel(11.minutes) do
        Gitlab::Versions.new('foo/bar', gitlab_client: gitlab_client).call
      end
    end

    it 'forces tags and branches update' do
      expect(gitlab_client).to receive(:branches).and_return([Response.new('b1')]).twice
      expect(gitlab_client).to receive(:tags).and_return([Response.new('t1')]).twice

      Gitlab::Versions.new('foo/bar',
                           gitlab_client: gitlab_client,
                           force_reload: true).call
      Gitlab::Versions.new('foo/bar',
                           gitlab_client: gitlab_client,
                           force_reload: true).call
    end
  end
end