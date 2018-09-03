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
      expect { pill_list([build(:project)]) }.to raise_error NoMethodError
    end

    it 'uses block to render name' do
      item = 'item'

      expect(pill_list([item]) { |i| "my #{i}" }).
        to eq(
          '<ul class="list-inline">'\
          '<li><span class="label label-info label-xs">my item</span></li>'\
          '</ul>'
        )
    end
  end

  describe '#global_access_methods_hint' do
    it 'returns nil when there are no global access methods' do
      expect(global_access_methods_hint).to eq nil
    end

    it 'lists all global access method names' do
      access_methods = create_list(:access_method, 2)
      expect(global_access_methods_hint).to include access_methods[0].name
      expect(global_access_methods_hint).to include access_methods[1].name
    end
  end
end
