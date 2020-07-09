# frozen_string_literal: true

namespace :compute_sites do
  desc 'Seed known compute sites'

  task seed: :environment do
    def get_full_name(name)
      full_name_mapping = { krk: 'Cyfronet: Prometheus',
                            lrz: 'LRZ',
                            lrzdtn: 'LRZ dtn',
                            lrzcluster: 'LRZ cluster',
                            lrzdss: 'LRZ dss',
                            snedtn: 'SNE dtn',
                            ams: 'Amsterdam' }
      full_name_mapping.fetch(name, 'placeholder name for unknown service')
    end

    Lobcder::Service.new(:uc1).folders.each do |name, values|
      ComputeSite.find_or_create_by!(name: name.to_s, full_name: get_full_name(name),
                                     host: values[:host])
    end
  end
end
