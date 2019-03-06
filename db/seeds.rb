# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# creating an admin user with owned admin and supervisor groups
admin = User.find_by(email: 'admin@host.domain')
admin ||= User.create(first_name: 'admin', last_name: 'admin', email: 'admin@host.domain',
                      password: 'admin123', password_confirmation: 'admin123', state: :approved)

%w[admin supervisor].map do |role_name|
  group = Group.find_or_initialize_by(name: role_name)
  group.user_groups.build(user: admin, owner: true)
  group.save!
end

TYPE_PATTERNS = {
  /(^imaging_.*\.zip$)|(file\.zip)/ => 'image',
  /^segmentation_.*\.zip$/ => 'segmentation_result',
  /^fluidFlow\.cas$/ => 'fluid_virtual_model',
  /^structural_vent\.dat$/ => 'ventricle_virtual_model',
  /^fluidFlow.*\.dat$/ => 'blood_flow_result',
  /^fluidFlow.*\.cas$/ => 'blood_flow_model',
  /^0DModel_input\.csv$/ => 'estimated_parameters',
  /^Outfile\.csv$/ => 'heart_model_output',
  /^.*Trunc.*off$/i => 'truncated_off_mesh',
  /^.*\.off$/ => 'off_mesh',
  /^.*\.\b(png|bmp|jpg)\b$/ => 'graphics',
  /^.*\.dxrom$/ => 'response_surface',
  /^ValveChar\.dat$/ => 'pressure_drops',
  /^OutFileGA\.csv$/ => 'parameter_optimization_result',
  /^OutSeries1\.csv$/ => 'data_series_1',
  /^OutSeries2\.csv$/ => 'data_series_2',
  /^OutSeries3\.csv$/ => 'data_series_3',
  /^OutSeries4\.csv$/ => 'data_series_4',
  /^ProvFile\.txt$/ => 'provenance'
}.freeze

TYPE_PATTERNS.each do |pattern, data_type|
  DataFileType.find_or_initialize_by(data_type: data_type) do |dft|
    dft.pattern = pattern.source
    dft.save!
  end
end
