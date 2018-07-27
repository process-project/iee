# frozen_string_literal: true

require 'rails_helper'

describe Projects::Destroy do
  include WebDavSpecHelper

  let(:user) { create(:user) }
  let!(:project) { create(:project) }

  it 'remove project from db' do
    webdav = instance_double(Net::DAV)
    allow(webdav).to receive(:exists?)
    allow(webdav).to receive(:delete)

    expect { described_class.new(user, project, client: webdav).call }.
      to change { Project.count }.by(-1)
  end

  it 'removes project webdav directory' do
    webdav = instance_double(Net::DAV)

    allow(webdav).to receive(:exists?).and_return(true)
    expect(webdav).to receive(:delete).with("test/projects/#{project.project_name}/")

    described_class.new(user, project, client: webdav).call
  end

  it 'returns true when project is removed' do
    webdav = instance_double(Net::DAV)
    allow(webdav).to receive(:exists?)
    allow(webdav).to receive(:delete)

    result = described_class.new(user, project, client: webdav).call

    expect(result).to be_truthy
  end

  it 'don\'t remove project when cannot remove webdav project directory' do
    webdav = web_dav_with_http_server_exception

    expect { described_class.new(user, project, client: webdav).call }.
      to_not(change { Project.count })
  end

  it 'returns false when project cannot be removed' do
    webdav = web_dav_with_http_server_exception

    result = described_class.new(user, project, client: webdav).call

    expect(result).to be_falsy
  end

  def web_dav_with_http_server_exception
    instance_double(Net::DAV).tap do |webdav|
      allow(webdav).to receive(:exists?).and_return(true)
      allow(webdav).to receive(:delete).
        and_raise(Net::HTTPServerException.new(403, 'Error'))
    end
  end
end
