# frozen_string_literal: true

module Liquid
  class StageIn < Liquid::Tag
    def initialize(tag_name, type, tokens)
      super
      @type = type
      @name = nil
    end

    def render(context)
      data_file = context.registers[:pipeline].data_file(@type.strip)
      file_name = @name || data_file&.name
      url = data_file&.url

      "curl -H \"Authorization: Bearer #{context['token']}\" \"#{url}\" "\
        ">> \"$SCRATCHDIR/#{file_name}\" --fail"
    end
  end
end
