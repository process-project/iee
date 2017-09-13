# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable BlockLength
shared_examples 'a Rimrock-based ready to run step' do
  let(:generic_template_fetcher) do
    class_double(Gitlab::GetFile).tap do |fetcher|
      allow(fetcher).to receive_message_chain(:new, :call) { 'script' }
    end
  end

  let(:generic_revision_fetcher) do
    class_double(Gitlab::Revision).tap do |fetcher|
      allow(fetcher).to receive_message_chain(:new, :call) { 'rev' }
    end
  end

  it 'creates RimrockComputation' do
    expect { described_class.create(pipeline, {}) }.
      to change { RimrockComputation.count }.by(1)
  end

  it 'get tag or branch from params' do
    computation = described_class.create(pipeline, tag_or_branch: 'my-tag')
    expect(computation.tag_or_branch).to eq('my-tag')
  end

  it 'returns a RimrockComputation object' do
    computation = described_class.create(pipeline, {})
    expect(computation.class).to eq RimrockComputation
  end

  it 'starts a Rimrock job' do
    expect(Rimrock::StartJob).to receive(:perform_later)

    computation.assign_attributes(tag_or_branch: 'master')
    service = described_class.new(computation,
                                  template_fetcher: generic_template_fetcher,
                                  revision_fetcher: generic_revision_fetcher)
    service.run
  end

  it 'is runnable' do
    expect(described_class.new(computation).runnable?).
      to be_truthy
  end

  it 'changes computation status to :new' do
    allow(Rimrock::StartJob).to receive(:perform_later)

    described_class.new(computation,
                        template_fetcher: generic_template_fetcher,
                        revision_fetcher: generic_revision_fetcher).run

    expect(computation.status).to eq 'new'
  end
end
# rubocop:enable BlockLength
