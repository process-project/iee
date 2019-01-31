# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Files synchronization API' do
  let(:auth_header) { { 'X-FILESTORE-TOKEN' => 'token' } }

  it 'returns unauthorized when file store token is not set in env' do
    mock_filestore_token_env(nil)

    post api_files_path, headers: auth_header

    expect(response.status).to eq(401)
  end

  it 'returns unauthorized when wrong token' do
    mock_filestore_token_env('secret')

    post api_files_path, headers: auth_header

    expect(response.status).to eq(401)
  end

  context 'authorized request' do
    before { mock_filestore_token_env('token') }
    before { ActiveJob::Base.queue_adapter = :test }
    after { ActiveJob::Base.queue_adapter = :inline }

    it 'creates new data files' do
      post api_files_path,
           params: { paths: ['/a/b.txt', '/a/b/c.txt'] },
           headers: auth_header

      expect(response.status).to eq(201)
      expect(DataFiles::CreateJob).
        to have_been_enqueued.
        with(['/a/b.txt', '/a/b/c.txt'])
    end

    it 'destroys data files' do
      delete api_files_path,
             params: { paths: ['/a/b.txt', '/a/b/c.txt'] },
             headers: auth_header

      expect(response.status).to eq(200)
      expect(DataFiles::DestroyJob).
        to have_been_enqueued.
        with(['/a/b.txt', '/a/b/c.txt'])
    end

    it 'destroys data files when given as query param' do
      delete api_files_path(paths: '/a/b.txt,/a/b/c.txt'),
             headers: auth_header

      expect(response.status).to eq(200)
      expect(DataFiles::DestroyJob).
        to have_been_enqueued.
        with(['/a/b.txt', '/a/b/c.txt'])
    end
  end

  def mock_filestore_token_env(value)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('FILESTORE_SECRET').and_return(value)
  end
end
