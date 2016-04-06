class DataFile < ActiveRecord::Base
  enum data_type: [ :cfd_mesh ]

  belongs_to :patient

  validates :name, :data_type, :patient, presence: true
end
