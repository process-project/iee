# frozen_string_literal: true
require 'rails_helper'

describe Pipelines::Create do
  let(:user) { create(:user) }

  it 'creates new pipeline in db' do
    webdav = instance_double(Net::DAV)
    allow(webdav).to receive(:exists?)
    allow(webdav).to receive(:mkdir)

    expect { described_class.new(user, build(:pipeline), client: webdav).call }.
      to change { Pipeline.count }.by(1)
  end

  it 'creates pipeline webdav directory' do
    webdav = instance_double(Net::DAV)
    patient = create(:patient)
    new_pipeline = build(:pipeline, patient: patient)

    allow(webdav).to receive(:exists?).and_return(false)
    expect(webdav).to receive(:mkdir).with(patient.case_number)
    expect(webdav).to receive(:mkdir).with("#{patient.case_number}/pipelines")
    expect(webdav).to receive(:mkdir).with("#{patient.case_number}/pipelines/1")

    described_class.new(user, new_pipeline, client: webdav).call
  end

  it 'don\'t create db pipeline when web dav dir cannot be created' do
    webdav = web_dav_with_http_server_exception

    expect { described_class.new(user, build(:pipeline), client: webdav).call }.
      to_not change { Pipeline.count }
  end

  it 'set error message when web dav dir cannot be created' do
    webdav = web_dav_with_http_server_exception
    new_pipeline = build(:pipeline)

    described_class.new(user, new_pipeline, client: webdav).call

    expect(new_pipeline.errors[:name]).
      to include(I18n.t('activerecord.errors.models.pipeline.create_dav403'))
  end

  def web_dav_with_http_server_exception
    instance_double(Net::DAV).tap do |webdav|
      allow(webdav).to receive(:exists?).and_return(false)
      allow(webdav).to receive(:mkdir).
        and_raise(Net::HTTPServerException.new(403, 'Error'))
    end
  end
end
