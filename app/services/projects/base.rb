# frozen_string_literal: true

module Projects
  class Base < ProjectWebdav
    def initialize(user, project, options = {})
      super(user, options)
      @project = project
    end

    def call
      Project.transaction { internal_call }
      @project
    end
  end
end
