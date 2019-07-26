require 'inspec/utils/filter'

class HabitatServices < Inspec.resource(1)
  name 'habitat_services'
  desc 'Verifies multiple services'
  example "
    describe habitat_services.where { release <= '20180101000000' }  do
      it { should_not exist }
    end
  "
  supports platform: 'habitat'

  # Underlying FilterTable implementation.
  filter = FilterTable.create
  filter.register_column(:origins, field: :origin, style: :simple)
  filter.register_column(:names, field: :name, style: :simple)
  filter.register_column(:releases, field: :release, style: :simple)
  filter.register_column(:versions, field: :version, style: :simple)
  filter.register_column(:dependency_names, field: :dependency_names, style: :simple)
  filter.register_column(:update_strategies, field: :update_strategy, style: :simple)
  filter.register_column(:topologies, field: :topology, style: :simple)
  filter.install_filter_methods_on_resource(self, :fetch_data)

  def exists?
    exist?
  end

  # Returns Array of Hashes, each with params suitable for passing to `habitat_service` (singular)
  def habitat_service_params
    raw_data.map { |row| { origin: row[:origin], name: row[:name] } }
  end

  private

  # Return Array of Hashes for FilterTable
  def fetch_data
    # Prefer the API, it is much richer
    if inspec.backend.api_options_provided?
      fetch_data_by_api
    else
      fetch_data_by_cli
    end
  end

  def fetch_data_by_api
    raw_services = inspec.backend.habitat_api_client.get_path('/services').body
    raw_services.map do |svc_entry|
      {
        name: svc_entry[:pkg][:name],
        version: svc_entry[:pkg][:version],
        origin: svc_entry[:pkg][:origin],
        release: svc_entry[:pkg][:release],
        dependency_names: svc_entry[:pkg][:deps].map { |d| "#{d[:origin]}/#{d[:name]}" },
        update_strategy: svc_entry[:update_strategy],
        topology: svc_entry[:topology],
      }
    end
  end

  def fetch_data_by_cli
    lines = inspec.backend.run_hab_cli('svc status').stdout.split("\n")
    lines.shift # Ignore header line
    lines.map do |line|
      fields = line.split(/\s+/)
      idents = fields.first.split('/')
      {
        origin: idents[0],
        name: idents[1],
        version: idents[2],
        release: idents[3],
        topology: fields[1],
        # deps, update strat not available via CLI svc
        dependency_names: [],
        update_strategy: nil,
      }
    end
  end
end
