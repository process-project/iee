# frozen_string_literal: true

class SingularityComputation < Computation
  validates :script, presence: true, unless: :created?
  validates :container_name, presence: true
  validates :container_tag, presence: true
  validates :compute_site, presence: true

  def need_directory_structure?
    True
  end
end
