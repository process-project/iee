# frozen_string_literal: true

class LobcderComputation < Computation
  validates :track_id, presence: true

  def runnable?
    # TODO: implement
  end
end
