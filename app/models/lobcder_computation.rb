# frozen_string_literal: true

class LobcderComputation < Computation
  validates :track_id, presence: true

  def runnable?
    computation.prev.success? # TODO: implement prev and next
  end
end
