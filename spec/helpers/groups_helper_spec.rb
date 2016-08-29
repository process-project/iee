
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe GroupsHelper do
  it 'print names list' do
    g1 = build(:group, name: 'g1')
    g2 = build(:group, name: 'g2')

    expect(name_list([g1, g2])).to eq('g1, g2')
  end
end
