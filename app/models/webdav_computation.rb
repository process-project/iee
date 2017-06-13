# frozen_string_literal: true
class WebdavComputation < Computation
  validates :script, absence: true
  validates :output_path, presence: true
end
