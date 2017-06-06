# frozen_string_literal: true
class Pipeline < ApplicationRecord
  belongs_to :patient
  belongs_to :user

  validate :set_iid, on: :create
  validates :iid, presence: true, numericality: true
  validates :name, presence: true

  def to_param
    iid.to_s
  end

  private

  def set_iid
    self.iid = patient.pipelines.maximum(:iid).to_i + 1 if iid.blank?
  end
end