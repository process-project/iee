# frozen_string_literal: true

module Projects
  class Details
    def initialize(project, user)
      @project = project
      @token = user.token
    end

    def call
      "Placeholder for project's details"
    end
  end
end
