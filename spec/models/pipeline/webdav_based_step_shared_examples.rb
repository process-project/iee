# frozen_string_literal: true
require 'rails_helper'

shared_examples 'a Webdav-based ready to run step' do
  it 'creates WebdavComputation' do
    expect { described_class.new(pipeline).create }.
      to change { WebdavComputation.count }.by(1)
  end

  it 'returns a WebdavComputation object' do
    allow(Webdav::StartJob).to receive(:perform_later)

    computation = described_class.new(pipeline).create

    expect(computation.class).to eq WebdavComputation
  end

  it 'starts a Webdav job' do
    expect(Webdav::StartJob).to receive(:perform_later)

    described_class.new(pipeline).run
  end

  it 'changes computation status to :new' do
    allow(Webdav::StartJob).to receive(:perform_later)

    computation = described_class.new(pipeline).run

    expect(computation.status).to eq 'new'
  end
end
