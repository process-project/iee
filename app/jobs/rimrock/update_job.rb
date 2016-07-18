module Rimrock
  class UpdateJob < ApplicationJob
    queue_as :computation

    def perform(user)
      Rimrock::Update.new(user, on_finish_callback: Updater).call
    end

    private

    class Updater
      def initialize(computation)
        @computation = computation
      end

      def call
        patient = @computation.patient
        user = @computation.user
        patient && user && DataFileSynchronizer.new(patient, user).call
      end
    end
  end
end
