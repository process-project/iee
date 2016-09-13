# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ServicesHelper do
  describe '#pill_list' do
    it 'prints "pilled" names list' do
      g1 = build(:group, name: 'g1')
      g2 = build(:group, name: 'g2')

      expect(pill_list([g1, g2])).
        to eq(
          '<ul class="list-inline">'\
          '<li><span class="label label-info label-xs">g1</span></li>'\
          '<li><span class="label label-info label-xs">g2</span></li>'\
          '</ul>'
        )
    end

    it 'prints empty list for empty collection' do
      expect(pill_list([])).to eq('<ul class="list-inline"></ul>')
      expect(pill_list(nil)).to eq('<ul class="list-inline"></ul>')
    end

    it 'raises error if items have no names' do
      expect { pill_list([build(:patient)]) }.to raise_error NoMethodError
    end
  end
end
