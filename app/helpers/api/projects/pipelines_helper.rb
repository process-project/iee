# frozen_string_literal: true

module Api
  module Projects
    module PipelinesHelper
      def available_flows_for(uc)
        Flow.flows_for(uc.downcase.to_sym).keys
      end
    end
  end
end
