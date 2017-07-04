# frozen_string_literal: true

class ResourceManager < ApplicationRecord
  include UserOrGroupConcern

  belongs_to :resource
end
