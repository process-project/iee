# frozen_string_literal: true

module Liquid
  class StageOut < Liquid::Tag
    def initialize(tag_name, relative_path, tokens)
      super
      @relative_path = relative_path.strip
    end

    def render(context)
      filename ||= File.basename(@relative_path)

      "curl -X PUT --data-binary @#{@relative_path} "\
      '-H "Content-Type:application/octet-stream"'\
      " -H \"Authorization: Bearer #{context['token']}\""\
      " \"#{File.join(context.registers[:pipeline].outputs_url, filename)}\""
    end
  end
end
