# frozen_string_literal: true

require 'liquid/stage_in'
require 'liquid/stage_out'
require 'liquid/clone_repo'

Liquid::Template.register_tag('stage_in', Liquid::StageIn)
Liquid::Template.register_tag('stage_out', Liquid::StageOut)
Liquid::Template.register_tag('clone_repo', Liquid::CloneRepo)
