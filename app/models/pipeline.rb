# frozen_string_literal: true

class Pipeline < ApplicationRecord
  enum mode: [:automatic, :manual]

  belongs_to :patient
  belongs_to :user

  # Inputs and outputs relation stores pipeline specific data files
  has_many :inputs,
           class_name: 'DataFile',
           foreign_key: 'input_of_id',
           dependent: :destroy

  has_many :outputs,
           class_name: 'DataFile',
           foreign_key: 'output_of_id',
           dependent: :destroy

  has_many :computations,
           dependent: :destroy

  validate :set_iid, on: :create
  validates :iid, presence: true, numericality: true
  validates :name, presence: true
  validates :mode, presence: true
  validates :flow, inclusion: { in: Flow.types.map(&:to_s) }

  scope :automatic, -> { where(mode: :automatic) }
  scope :latest, ->(nr = 3) { reorder(created_at: :desc).limit(nr) }

  def steps
    Flow.steps(flow)
  end

  def to_param
    iid.to_s
  end

  def outputs_dir(prefix = patient.pipelines_dir)
    File.join(root_dir(prefix), 'outputs', '/')
  end

  def outputs_url
    outputs_dir(patient.pipelines_url)
  end

  def inputs_dir(prefix = patient.pipelines_dir)
    File.join(root_dir(prefix), 'inputs', '/')
  end

  def inputs_url
    inputs_dir(patient.pipelines_url)
  end

  def root_dir(prefix = patient.pipelines_dir)
    File.join(prefix, iid.to_s, '/')
  end

  def data_file(data_type)
    DataFile.
      where(patient: patient,
            output_of: [nil, self],
            input_of: [nil, self],
            data_type: data_type).
      order(:output_of_id, :input_of_id).
      first
  end

  def status
    @status ||= calculate_status
  end

  def owner_name
    user&.name || '(deleted user)'
  end

  private

  def calculate_status
    if computations.all?(&:success?)
      :success
    elsif computations.any?(&:error?)
      :error
    elsif computations.any?(&:active?)
      :running
    else
      :waiting
    end
  end

  def set_iid
    self.iid = patient.pipelines.maximum(:iid).to_i + 1 if iid.blank?
  end
end
