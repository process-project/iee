module Liquid
  class Multiply < Liquid::Tag
    def initialize(tag_name, factor, tokens)
      super
      @factor = factor.to_f
    end

    def render(context)
      (@factor * context["multiply_by"].to_f).to_s
    end
  end
end
