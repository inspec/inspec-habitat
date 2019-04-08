class HabitatPackage < Inspec.resource(1)
  name 'habitat_package'
  desc 'Verifies an installed Habitat package'
  example "
    describe habitat_package(origin: 'core', name: 'httpd') do
      it                     { should exist }
      its('version')         { should eq '2.4.35'}
      its('release')         { should eq '20190307151146'}
      its('identifier')      { should eq 'core/httpd/2.4.35/20190307151146' }
    end
  "
  supports platform: 'habitat'

  attr_reader :name, :origin, :release, :version

  def initialize(params)
    if params.is_a? String
      @origin, @name, @version, @release = params.split('/')
    elsif params.is_a? Hash
      @origin = params[:origin]
      @name   = params[:name]
      @version = params[:version]
      @release = params[:release]
    else
      raise ArgumentError, "habitat_package accepts either a String (package identifier) or a Hash (components of an identifier). Saw #{params}, a #{params.class.name}"
    end

    super()

    @exists = nil
    perform_existence_check
  end

  def exists?
    @exists
  end

  def exist?
    @exists
  end

  def identifier
    id = "#{origin}/#{name}"
    id += "/#{version}" if version
    id += "/#{release}" if version && release
    id
  end

  def to_s
    "Habitat Service #{identifier}"
  end

  def specific_install_root
    return nil unless exists?

    pkgs_install_root + '/' + identifier
  end

  def pkgs_install_root
    self.class.pkgs_install_root
  end

  def self.pkgs_install_root
    return nil unless inspec.backend.cli_options_provided?
    return @pkgs_root if @pkgs_root

    # Strategy: we know core/hab is installed, and we know the package
    # install path is embedded in its PATH env var.
    hab_ident = inspec.backend.run_command('hab pkg list core/hab').stdout.split("\n").first
    env_lines = inspec.backend.run_command('hab pkg env core/hab').stdout
    # export PATH="/hab/pkgs/core/hab/0.78.0/20190313115951/bin"
    path_line = env_lines.split("\n").detect { |l| l.include? 'PATH=' }
    @pkgs_root = path_line.match(%r{="(.+)/#{hab_ident}.*"})[1]
  end

  private

  def perform_existence_check
    unless inspec.backend.cli_options_provided?
      @exists = false
      return
    end

    package_idents = inspec.backend.run_hab_cli("pkg list #{identifier}").stdout.split("\n").reject(&:empty?)
    if package_idents.empty?
      @exists = false
      return
    end

    if package_idents.count > 1
      raise ArgumentError, 'Multiple package versions/releases matched - use more specific parameters, or use habitat_packages to enumerate multiple installed packages.'
    end

    @origin, @name, @version, @release = package_idents.first.split('/')
    @exists = true
  end
end
