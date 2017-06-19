# frozen_string_literal: true
require 'rails_helper'
require 'webdav/client'

describe Pipelines::Destroy do
  include WebDavSpecHelper

  let(:user) { create(:user) }
  let!(:pipeline) { create(:pipeline, user: user) }

  it 'remove pipeline from db' do
    webdav = instance_double(Webdav::Client)
    allow(webdav).to receive(:delete)

    expect { described_class.new(pipeline, client: webdav).call }.
      to change { Pipeline.count }.by(-1)
  end

  it 'removes pipeline webdav directory' do
    webdav = instance_double(Webdav::Client)

    expect(webdav).to receive(:delete).
      with("test/patients/#{pipeline.patient.case_number}/pipelines/1/")

    described_class.new(pipeline, client: webdav).call
  end

  it 'returns true when pipeline is removed' do
    webdav = instance_double(Webdav::Client)
    allow(webdav).to receive(:delete)

    result = described_class.new(pipeline, client: webdav).call

    expect(result).to be_truthy
  end

  it 'don\'t remove pipeline when cannot remove webdav pipeline directory' do
    webdav = web_dav_with_http_server_exception

    expect { described_class.new(pipeline, client: webdav).call }.
      to_not change { Patient.count }
  end

  it 'returns false when pipeline cannot be removed' do
    webdav = web_dav_with_http_server_exception

    result = described_class.new(pipeline, client: webdav).call

    expect(result).to be_falsy
  end

  def web_dav_with_http_server_exception
    instance_double(Webdav::Client).tap do |webdav|
      allow(webdav).to receive(:delete).
        and_raise(Net::HTTPServerException.new(403, 'Error'))
    end
  end
end
