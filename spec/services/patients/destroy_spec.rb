# frozen_string_literal: true
require 'rails_helper'

describe Patients::Destroy do
  include WebDavSpecHelper

  let(:user) { create(:user) }
  let!(:patient) { create(:patient) }

  it 'remove patient from db' do
    webdav = instance_double(Net::DAV)
    allow(webdav).to receive(:exists?)
    allow(webdav).to receive(:delete)

    expect { described_class.new(user, patient, client: webdav).call }.
      to change { Patient.count }.by(-1)
  end

  it 'removes patient webdav directory' do
    webdav = instance_double(Net::DAV)

    allow(webdav).to receive(:exists?).and_return(true)
    expect(webdav).to receive(:delete).with(patient.case_number)

    described_class.new(user, patient, client: webdav).call
  end

  it 'returns true when patient is removed' do
    webdav = instance_double(Net::DAV)
    allow(webdav).to receive(:exists?)
    allow(webdav).to receive(:delete)

    result = described_class.new(user, patient, client: webdav).call

    expect(result).to be_truthy
  end

  it 'don\'t remove patient when cannot remove webdav patient directory' do
    webdav = web_dav_with_http_server_exception

    expect { described_class.new(user, patient, client: webdav).call }.
      to_not change { Patient.count }
  end

  it 'returns false when patient cannot be removed' do
    webdav = web_dav_with_http_server_exception

    result = described_class.new(user, patient, client: webdav).call

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
