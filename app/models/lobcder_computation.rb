# frozen_string_literal: true

class LobcderComputation < Computation
  def runnable?
    prev.nil? || prev.success?
  end
end
