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
    service.dig('pkg', 'version') unless service.nil?
  end

  def release
    service.dig('pkg', 'release') unless service.nil?
  end

  def topology
    service.dig('topology') unless service.nil?
  end

  def update_strategy
    service.dig('update_strategy') unless service.nil?
  end

  def deps
    service.dig('pkg', 'deps') unless service.nil?
  end

  def exists?
    !service.nil?
  end

  def pkg_id
    service.dig('pkg', 'ident') unless service.nil?
  end

  def to_s
    "Habitat Service #{pkg_name}"
  end

  private

  def pkg_name
    "#{origin}/#{name}"
  end

  def service
    return @services if defined?(@services)

    services = inspec.backend.habitat_client.services.select { |svc|
      svc['pkg']['origin'] == origin &&
        svc['pkg']['name'] == name
    }

    if services.one?
      @services = services[0]
    else
      @services = nil
    end
  end
end
