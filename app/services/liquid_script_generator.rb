# frozen_string_literal: true

class LiquidScriptGenerator
  def initialize(computation, template)
    @computation = computation
    @template = template
  end

  def call
    return unless @template

    tpl = Liquid::Template.parse(@template)
    tpl.render({ 'token' => token, 'case_number' => case_number,
                 'revision' => revision, 'grant_id' => grant_id },
               registers: { pipeline: pipeline },
               filters: [])
  end

  private

  attr_reader :computation

  delegate :pipeline, to: :computation
  delegate :patient, to: :pipeline
  delegate :user, to: :pipeline
  delegate :revision, to: :computation
  delegate :patient, to: :pipeline
  delegate :token, to: :user
  delegate :case_number, to: :patient

  def grant_id
    Rails.application.config_for('eurvalve')['grant_id']
  end
end
