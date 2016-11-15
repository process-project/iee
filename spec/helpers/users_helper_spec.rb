# frozen_string_literal: true
require 'rails_helper'

describe UsersHelper do
  include UsersHelper

  describe 'user_name' do
    it 'render user name and email' do
      user = double(name: 'foo bar', email: 'foo@bar.pl')
      expect(user_name(user)).
        to match(/foo bar<small class="light">\(foo@bar.pl\)/)
    end
  end

  describe 'raw_user_name' do
    it 'render user name and email' do
      user = double(name: 'foo bar', email: 'foo@bar.pl')
      expect(raw_user_name(user)).to eq('foo bar (foo@bar.pl)')
    end
  end
end
