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

    def seek_test(opts)
      describe 'when seeking the resource' do
        let(:unit_test_path) { File.expand_path(File.join('test', 'unit')) }
        let(:unit_fixture_path) { File.join(unit_test_path, 'fixtures') }

        describe 'when the resource is locatable' do
          opts[:hit_params].each do |hit_param_set|
            it "should be found with #{hit_param_set}" do
              InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, opts[:fixture])
              obj = opts[:klass].new(hit_param_set) # No exception
              obj.wont_be_nil
              obj.exists?.must_equal true
            end
          end
        end

        # describe 'when the resource is not locatable' do
        #   it 'should throw an exception'
        # end
      end
    end

    # How to setup fixtures:
    # CLI:
    # API:
    # DRYing this up was very difficult, and I am sure there is a better way.
    def mock_inspec_context_object(test_cxt, fixture)
      test_cxt.instance_eval do
        inspec_cxt = mock
        hab_cxn = mock

        inspec_cxt.stubs(:backend).returns(hab_cxn)

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

        if fixture.key?(:api)
          hab_cxn.stubs(:api_options_provided?).returns(true)
          htg = mock
          hab_cxn.stubs(:habitat_api_client).returns(htg)
          resp = mock
          resp.stubs(:code).returns(fixture[:api][:code])
          if fixture[:api][:file]
            api_path = File.join(unit_fixture_path, fixture[:api][:file])
            resp.stubs(:body).returns(JSON.parse(File.read(api_path), symbolize_names: true))
          end
          htg.stubs(:get_path).with(fixture[:api][:path]).returns(resp)
        else
          hab_cxn.stubs(:api_options_provided?).returns(false)
        end
        Inspec::Plugins::Resource.any_instance.stubs(:inspec).returns(inspec_cxt)

      end
    end
    module_function :mock_inspec_context_object
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
