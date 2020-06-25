# frozen_string_literal: true

module Projects
  class Base
    def initialize(user, project, options = {})
      @project = project
    end

    def call
      Project.transaction { internal_call }
      @project
    end
  end
end
