# frozen_string_literal: true

require 'liquid/stage_in'

Liquid::Template.register_tag('stage_in', Liquid::StageIn)
