# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Segmentation::FileUtils, type: :helper do
  let(:fname) { 'fname' }
  let(:full_path) { "/full/path/#{fname}" }
  it 'extracts filename from a full path' do
    expect(helper.strip_local_filename(full_path)).to eq fname
  end

  it 'returns file name when path component is missing' do
    expect(helper.strip_local_filename(fname)).to eq fname
  end
end
