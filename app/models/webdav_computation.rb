# frozen_string_literal: true

class WebdavComputation < Computation
  validates :script, absence: true
  validates :output_path, presence: true
  validates :run_mode, presence: true, unless: :created?

  private

  def created?
    status == 'created'
  end
end
