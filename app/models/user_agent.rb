# frozen_string_literal: true

class UserAgent < ApplicationRecord
  belongs_to :user

  #FIXME: validate at least name
end
