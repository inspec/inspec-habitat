require 'minitest/autorun'
require 'minitest/spec'
require 'mocha/minitest'

require 'train-habitat'

require 'byebug'
require 'json'

class Module
  include Minitest::Spec::DSL
end

#============================================================================#
#                          Actual Test Helper
#============================================================================#

module InspecHabitat
  module UnitTestHelper
    def check_definition(opts)
      it 'should meet the basic definition of a resource' do
        klass = opts[:klass]
        meta = klass.metadata

        klass.must_be :<, Inspec::Plugins::Resource
        meta.name.wont_be_empty
        meta.example.wont_be_empty
        meta.desc.wont_be_empty
        meta.supports.must_equal({ platform: 'habitat' })
        klass.instance_methods.must_include(:exist?)
        klass.instance_methods.must_include(:exists?)
      end
    end

    # How to setup fixtures:
    # Pass a fixture Hash to this method as the second arg.
    # {
    #   cli: { # Optional. If present, connection will say that CLI mode is available.
    #     cmd: 'svc status core/httpd', # This registers the stub, so it will only respond to this command
    #     stdout_file: 'svc-status-single.cli.txt', # A file under test/unit/fixtures, empty String if this key is absent
    #     stderr_file: 'some-other-file.cli.txt', # A file under test/unit/fixtures, empty String if this key is absent
    #     exit_status: 0,
    #   },
    #   api: { # Optional. If present, connection will say that API mode is available.
    #     path: '/services', # This registers the stub, so it will only respond to this path
    #     body_file: 'services-single.api.json', # A file under test/unit/fixtures, empty String if this key is absent
    #     code: 200
    #   },
    #   aux_cli: [ # If present, these commands are mocked as run_command (not run_hab_cli). Exit is always 0, no stderr.
    #     { cmd: 'cat /etc/whatever', stdout_file: 'somefile.txt' }
    #   ]
    # }

    # About this method.
    # DRYing this up was very difficult, and I am sure there is a better way.
    #  Problem 1: You can't just call this methd in an `it` block, because the
    # module is not included there. So, make it a module function, and call
    # it with its full name. Probably a better way.
    #  Problem 2: within the body of this, we need to call mock() and friends;
    # which means we need to be in an `it` block. So... and this is awful ...
    # pass the it block (which is `self`, within the it block) as the test
    # context and then perform a block-type instance-eval.
    def mock_inspec_context_object(test_cxt, fixture)
      test_cxt.instance_eval do
        inspec_cxt = mock
        hab_cxn = mock

        inspec_cxt.stubs(:backend).returns(hab_cxn)

        configure_cli_stubs(hab_cxn, fixture)
        configure_api_stubs(hab_cxn, fixture)
        configure_aux_cli_stubs(hab_cxn, fixture)

        Inspec::Plugins::Resource.any_instance.stubs(:inspec).returns(inspec_cxt)
        Inspec::Plugins::Resource.stubs(:inspec).returns(inspec_cxt)
      end
    end
    module_function :mock_inspec_context_object # rubocop:disable Style/AccessModifierDeclarations

    def configure_cli_stubs(hab_cxn, fixture) # rubocop:disable Metrics/AbcSize
      if fixture.key?(:cli)
        hab_cxn.stubs(:cli_options_provided?).returns(true)
        run_result = mock
        run_result.stubs(:exit_status).returns(fixture[:cli][:exit_status])

        out = fixture[:cli][:stdout_file] ? File.read(File.join(unit_fixture_path, fixture[:cli][:stdout_file])) : ''
        run_result.stubs(:stdout).returns(out)
        err = fixture[:cli][:stderr_file] ? File.read(File.join(unit_fixture_path, fixture[:cli][:stderr_file])) : ''
        run_result.stubs(:stderr).returns(err)

        hab_cxn.stubs(:run_hab_cli).with(fixture[:cli][:cmd]).returns(run_result)
      else
        hab_cxn.stubs(:cli_options_provided?).returns(false)
      end
    end

    def configure_api_stubs(hab_cxn, fixture)
      if fixture.key?(:api)
        hab_cxn.stubs(:api_options_provided?).returns(true)
        htg = mock
        hab_cxn.stubs(:habitat_api_client).returns(htg)
        resp = mock
        resp.stubs(:code).returns(fixture[:api][:code])
        if fixture[:api][:body_file]
          api_path = File.join(unit_fixture_path, fixture[:api][:body_file])
          resp.stubs(:body).returns(JSON.parse(File.read(api_path), symbolize_names: true))
        end
        htg.stubs(:get_path).with(fixture[:api][:path]).returns(resp)
      else
        hab_cxn.stubs(:api_options_provided?).returns(false)
      end
    end

    def configure_aux_cli_stubs(hab_cxn, fixture)
      if fixture.key?(:aux_cli)
        fixture[:aux_cli].each do |cmd_info|
          run_result = mock
          run_result.stubs(:exit_status).returns(0)
          run_result.stubs(:stderr).returns('')
          out = File.read(File.join(unit_fixture_path, cmd_info[:stdout_file]))
          run_result.stubs(:stdout).returns(out)
          hab_cxn.stubs(:run_command).with(cmd_info[:cmd]).returns(run_result)
        end
      end
    end
  end
end

#============================================================================#
#                          Resource DSL Mocking
#============================================================================#

# Dummy - this is the superclass
# Loading enough of inspec to get this is
# a nightmare, though; so we just fake it here.
module Inspec
  module Plugins
    class Resource
      class << self
        attr_reader :metadata
      end

      def self.name(val)
        @metadata ||= OpenStruct.new
        @metadata[:name] = val
      end

      def self.desc(val)
        @metadata ||= OpenStruct.new
        @metadata[:desc] = val
      end

      def self.supports(val)
        @metadata ||= OpenStruct.new
        @metadata[:supports] = val
      end

      def self.example(val)
        @metadata ||= OpenStruct.new
        @metadata[:example] = val
      end

      # Mock inspec context object
      # Will be re-mocked in various places
      def inspec
        nil
      end
    end
  end
end

# Returns the resource superclass
module Inspec
  def self.resource(_version)
    Inspec::Plugins::Resource
  end
end
