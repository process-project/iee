class Patient < ActiveRecord::Base
  enum procedure_status: [ :not_started, :imaging_uploaded, :virtual_model_ready, :after_blood_flow_simulation ]

  has_many :data_files, dependent: :destroy

  validates :case_number, :procedure_status, presence: true
  validates :case_number, uniqueness: true

  default_scope { order('case_number asc') }
end
