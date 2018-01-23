# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
shared_examples 'ready to run step' do
  include ActiveSupport::Testing::TimeHelpers
  let(:template_fetcher) do
    fetcher = class_double(Gitlab::GetFile)
    allow(fetcher).to receive_message_chain(:new, :call) { 'script' }

    fetcher
  end

  let(:revision_fetcher) do
    fetcher = class_double(Gitlab::Revision)
    allow(fetcher).to receive_message_chain(:new, :call) { 'revision' }

    fetcher
  end

  it 'is runnable' do
    expect(described_class.new(computation).runnable?).to be_truthy
  end

  it 'set computation start time to now' do
    now = Time.zone.local(2017, 1, 2, 7, 21, 34)
    travel_to now

    service = described_class.new(computation,
                                  template_fetcher: template_fetcher,
                                  revision_fetcher: revision_fetcher)
    computation.assign_attributes(revision: 'master')

    service.run

    expect(service.computation.started_at).to eq now

    travel_back
  end

  it 'sent notification after computation is started' do
    computation.update_attributes(tag_or_branch: 'master')
    updater = instance_double(ComputationUpdater)
    service = described_class.new(computation,
                                  template_fetcher: template_fetcher,
                                  revision_fetcher: revision_fetcher,
                                  updater: double(new: updater))

    expect(updater).to receive(:call)

    service.run
  end
end
# rubocop:enable Metrics/BlockLength

shared_examples 'not ready to run step' do
  it "raise error if patient's virtual model is not ready yet" do
    expect { described_class.new(computation).run }.
      to raise_error('Required inputs are not available')
  end

  it 'is not runnable' do
    expect(described_class.new(computation).runnable?).to be_falsy
  end
end
