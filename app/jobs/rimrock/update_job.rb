module Rimrock
  class UpdateJob < ActiveJob::Base
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
        patient = computation.patient
        patient && DataFileSynchronizer.new(patient).call
      end
    end
  end
end
