require "inspec/utils/filter"
require "inspec/exceptions"

class HabitatPackages < Inspec.resource(1)
  name "habitat_packages"
  desc "Verifies multiple installed packages"
  example "
    describe habitat_packages.where { release <= '20180101000000' }  do
      it { should_not exist }
    end
  "
  supports platform: "habitat"

  # Underlying FilterTable implementation.
  filter = FilterTable.create
  filter.register_column(:origins, field: :origin, style: :simple)
  filter.register_column(:names, field: :name, style: :simple)
  filter.register_column(:releases, field: :release, style: :simple)
  filter.register_column(:versions, field: :version, style: :simple)
  filter.install_filter_methods_on_resource(self, :fetch_data)

  def exists?
    exist?
  end

  # Returns Array of Hashes, each with params suitable for passing to `habitat_package` (singular)
  def habitat_package_params
    raw_data.map { |row| { origin: row[:origin], name: row[:name], version: row[:version], release: row[:release] } }
  end

  private

  # Return Array of Hashes for FilterTable
  def fetch_data
    # Only available by CLI
    return [] unless inspec.backend.cli_options_provided?

    lines = inspec.backend.run_hab_cli("pkg list --all").stdout.split("\n")
    lines.map do |line|
      ident = {}
      ident[:origin], ident[:name], ident[:version], ident[:release] = line.split("/")
      ident
    end
  end
end
