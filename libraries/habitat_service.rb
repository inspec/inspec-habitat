class HabitatService < Inspec.resource(1)
  name 'habitat_service'
  desc 'Verifies a Habitat Service'
  example "
    describe habitat_service(origin: 'core', name: 'httpd') do
      it                     { should exist }
      its('version')         { should eq '2.4.35'}
      its('topology')        { should eq 'standalone' }
      its('update_strategy') { should eq 'none' }
    end
  "
  supports platform: 'habitat'

  attr_reader :origin, :name

  def initialize(opts = {})
    super()
    @origin = opts[:origin]
    @name   = opts[:name]

    service
  end

  def version
    service&.dig(:pkg, :version)
  end

  def release
    service&.dig(:pkg, :release)
  end

  def topology
    service&.dig(:topology)
  end

  def update_strategy
    service&.dig(:update_strategy)
  end

  # TODO: check format of response here, likely want to return strings
  def dependencies
    service&.dig(:pkg, :deps) || []
  end

  def exists?
    !service.nil?
  end

  def exist?
    !service.nil?
  end

  def pkg_id
    service&.dig(:pkg, :ident)
  end

  def to_s
    "Habitat Service #{pkg_name}"
  end

  private

  def pkg_name
    "#{origin}/#{name}"
  end

  def service
    return @service if defined?(@service)

    # Prefer the API, it is much richer
    if inspec.backend.api_options_provided?
      services = inspec.backend.habitat_api_client.get_path('/services').body.select { |svc|
        svc[:pkg][:origin] == origin &&
          svc[:pkg][:name] == name
      }
      @service = services.one? ? services[0] : nil
    else

      service_check_result = inspec.backend.run_hab_cli("svc status #{origin}/#{name}")
      if service_check_result.exit_status == 1 && service_check_result.stderr.include?('Service not loaded')
        # No such service
        @service = nil
      else
        load_service_via_cli(service_check_result.stdout)
      end
    end
  end

  def load_service_via_cli(status_stdout)
    # package                           type        desired  state  elapsed (s)  pid   group
    # core/httpd/2.4.35/20190307151146  standalone  up       up     158169       1410  httpd.default
    @service = {}
    line = status_stdout.split("\n")[1] # Skip header
    fields = line.split(/\s+/)
    @service[:pkg] = {}
    @service[:pkg][:ident] = fields[0]
    @service[:topology] = fields[1]
    ident_fields = @service[:pkg][:ident].split('/')
    @service[:pkg][:origin] = ident_fields[0]
    @service[:pkg][:name] = ident_fields[1]
    @service[:pkg][:version] = ident_fields[2]
    @service[:pkg][:release] = ident_fields[3]
    # update_strategies, dependencies are not available via CLI svc
    @service
  end
end
