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
    "Habitat Package #{identifier}"
  end

  def installation_path
    return nil unless exists?

    "#{hab_install_root}/#{identifier}"
  end

  # Read dependency package IDs from the TDEPs file
  def dependency_ids
    return [] unless exists?
    return @dependency_ids if defined?(@dependency_ids)

    tdeps = inspec.backend.run_command("cat #{installation_path}/TDEPS").stdout
    @dependency_ids = tdeps.chomp.split("\n")
  end

  def dependency_names
    return [] unless exists?
    return @dependency_names if defined?(@dependency_names)

    @dependency_names = dependency_ids.map { |id| id.split('/')[0, 2].join('/') }
  end

  private

  def hab_install_root
    @hab_install_root ||= determine_hab_install_root
  end

  # Figure out the hab installation path by looking at the PATH of
  # a package known to be installed, and known to have a simple PATH
  # - hab itself is perfect for this.
  def determine_hab_install_root
    list_result = inspec.backend.run_hab_cli('pkg list core/hab')
    hab_spec = list_result.stdout.split("\n").first
    env_result = inspec.backend.run_hab_cli("pkg env #{hab_spec}")
    path_line = env_result.stdout.split("\n").detect { |l| l.include?('PATH') }
    path_line.tr!('\\', '/') # Force slashes to be backslashes to match package IDs
    # Like export PATH="/hab/pkgs/core/hab/0.81.0/20190507225645/bin"
    # Or set PATH="C:\hab\pkgs\core\hab\0.81.0\20190507225645\bin"
    match = path_line.match(%r{="(.+)[\\\/]#{hab_spec}})
    unless match
      # TODO: Inspec 3174 resource unable handling
      raise Inspec::Exceptions::ResourceFailed, 'Cannot determine habitat install root'
    end

    match[1]
  end

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
