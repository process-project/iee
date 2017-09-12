# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webdav::StartJob do
  it 'sets computation status to error if failed' do
    allow(Segmentation::Start).to receive_message_chain('new.call').and_raise
    computation = create(:computation)
    # rubocop:disable Lint/HandleExceptions
    begin
      described_class.perform_now(computation)
    rescue
      # we really want to swallow exception here
    end
    # rubocop:enable Lint/HandleExceptions
    computation.reload
    expect(computation.status).to eq 'error'
  end
end
