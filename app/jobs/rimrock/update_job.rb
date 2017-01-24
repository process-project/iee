# frozen_string_literal: true
module Rimrock
  class UpdateJob < ApplicationJob
    queue_as :computation

    def perform(user)
      Rimrock::Update.new(user, on_finish_callback: Updater).call
    end

    class Updater
      def initialize(computation)
        @computation = computation
      end

      def call
        patient = @computation.patient
        user = @computation.user
        patient && user && patient.execute_data_sync(user)
      end
    end
  end
end
