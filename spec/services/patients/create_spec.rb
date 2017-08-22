# frozen_string_literal: true

require 'rails_helper'

describe Patients::Create do
  let(:user) { create(:user) }
  let(:stranger) { build(:patient, case_number: '{ &*^%$#@![]":;.,<>/?\a stranger in the night}') }

  it 'creates new patient in db' do
    webdav = instance_double(Webdav::Client)
    allow(webdav).to receive(:r_mkdir)

    expect { described_class.new(user, build(:patient), client: webdav).call }.
      to change { Patient.count }.by(1)
  end

  it 'creates patient webdav directory' do
    webdav = instance_double(Webdav::Client)
    new_patient = build(:patient)

    expect(webdav).to receive(:r_mkdir).
      with("test/patients/#{new_patient.case_number}/inputs/")
    expect(webdav).to receive(:r_mkdir).
      with("test/patients/#{new_patient.case_number}/pipelines/")

    described_class.new(user, new_patient, client: webdav).call
  end

  it 'does not create db patient when web dav dir cannot be created' do
    webdav = web_dav_with_http_server_exception

    expect { described_class.new(user, build(:patient), client: webdav).call }.
      to_not(change { Patient.count })
  end

  it 'does not create webdav dir if db patient is invalid' do
    webdav = instance_double(Webdav::Client)
    expect(webdav).not_to receive(:r_mkdir)

    expect(stranger).not_to be_valid
    described_class.new(user, stranger, client: webdav).call
  end

  it 'set error message when web dav dir cannot be created' do
    webdav = web_dav_with_http_server_exception
    new_patient = build(:patient)

    described_class.new(user, new_patient, client: webdav).call

    expect(new_patient.errors[:case_number]).
      to include(I18n.t('activerecord.errors.models.patient.create_dav403'))
  end

  def web_dav_with_http_server_exception
    instance_double(Webdav::Client).tap do |webdav|
      allow(webdav).to receive(:r_mkdir).
        and_raise(Net::HTTPServerException.new(403, 'Error'))
    end
  end
end
