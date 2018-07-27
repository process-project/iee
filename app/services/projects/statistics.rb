# frozen_string_literal: true

module Projects
  class Statistics
    def initialize(projects, user)
      @projects = projects || []
      @token = user.token
    end

    def call
      fetch_statistics
    end

    private

    def fetch_statistics
      constraints = @projects.map { |p| project_constraint(p.project_name) }.join(',')
      client = DataSets::Client.new(@token,
                                    'project_statistics.json',
                                    '{project_id_constraints}' => constraints)
      create_details(client.call)
    rescue StandardError => e
      Rails.logger.error("Could not fetch project statistics with unknown error: #{e.message}")
      { status: :error, message: e.message }
    end

    def project_constraint(project_name)
      File.read(Rails.root.join('config', 'data_sets', 'payloads', 'project_id_constraint.part')).
        gsub('{project_name}', project_name)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def create_details(csv)
      entries = csv&.slice(1..-1) || []
      {
        status: :ok,
        count: entries.count,
        test: @projects.count - entries.count,
        berlin: entries.count { |p| p[0].include?('_B_') },
        sheffield: entries.count { |p| p[0].include?('_S_') },
        eindhoven: entries.count { |p| p[0].include?('-C-') },
        no_site: entries.count - entries.count { |p| p[0].index(/(_[BS]_|-C-)/) },
        aortic: entries.count { |p| p[0].index(/(_A_|-A-)/) },
        mitral: entries.count { |p| p[0].index(/(_M_|-M-)/) },
        no_diagnosis: entries.count - entries.count { |p| p[0].index(/(_[AM]_|-[AM]-)/) },
        females: entries.count { |p| p[2] == 'Female' },
        males: entries.count { |p| p[2] == 'Male' },
        no_gender: entries.count { |p| !%w[Male Female].include?(p[2]) },
        preop: entries.count { |p| p[1] == 'Pre-op' },
        postop: entries.count { |p| p[1] == 'Post-op' },
        no_state: entries.count { |p| !%w[Pre-op Post-op].include?(p[1]) }
      }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
