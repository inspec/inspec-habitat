require_relative './unit_helper'
require_relative '../../libraries/habitat_service'

# rubocop:disable Metrics/BlockLength
describe HabitatService do # rubocop:disable Metrics/BlockLength
  let(:unit_test_path) { File.expand_path(File.join('test', 'unit')) }
  let(:unit_fixture_path) { File.join(unit_test_path, 'fixtures') }

  extend InspecHabitat::UnitTestHelper

  check_definition(klass: HabitatService, name: 'habitat_service')

  #==========================================================================#
  #                             Resource Params
  #==========================================================================#

  describe 'when seeking the resource' do
    describe 'when the resource is locatable' do
      it 'should be found with via the api' do
        fixture = {
          api: {
            path: '/services',
            body_file: 'services-single.api.json',
            code: 200,
          },
        }
        InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

        obj = HabitatService.new(origin: 'core', name: 'nginx') # No exception
        obj.wont_be_nil
        obj.exists?.must_equal true
      end

      it 'should be found with via the cli' do
        fixture = {
          cli: {
            cmd: 'svc status core/httpd',
            stdout_file: 'svc-status-single.cli.txt',
            exit_status: 0,
          },
        }
        InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

        obj = HabitatService.new(origin: 'core', name: 'httpd') # No exception
        obj.wont_be_nil
        obj.exists?.must_equal true
      end
    end

    describe 'when the resource does not exist' do
      it 'should be not found with via the api' do
        fixture = {
          api: {
            path: '/services',
            body_file: 'services-single.api.json',
            code: 200,
          },
        }
        InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

        obj = HabitatService.new(origin: 'care', name: 'agaped') # No exception
        obj.wont_be_nil
        obj.exists?.wont_equal true
      end

      it 'should not be found with via the cli' do
        fixture = {
          cli: {
            cmd: 'svc status care/agaped',
            stderr_file: 'svc-status-miss.cli.txt',
            exit_status: 1,
          },
        }
        InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

        obj = HabitatService.new(origin: 'care', name: 'agaped') # No exception
        obj.wont_be_nil
        obj.exists?.wont_equal true
      end
    end
  end

  #==========================================================================#
  #                   Properties & Matchers - API mode
  #==========================================================================#

  describe 'when testing properties and matchers via the api' do
    let(:fixture) do
      {
        api: {
          path: '/services',
          body_file: 'services-single.api.json',
          code: 200,
        },
      }
    end
    let(:svc) { HabitatService.new(origin: 'core', name: 'nginx') }

    it 'should load properties correctly' do
      InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
      svc.version.must_equal '1.15.5'
      svc.release.must_equal '20181010011756'
      svc.dependency_names.must_be_kind_of Array
      svc.dependency_names[0].must_be_kind_of String
      svc.dependency_names[0].must_match %r{^\w+\/\w+$}
      svc.dependency_ids.must_be_kind_of Array
      svc.dependency_ids[0].must_be_kind_of String
      svc.dependency_ids[0].must_match %r{^\w+\/\w+/[0-9\.]+/\d{14}$}
      svc.pkg_id.must_match %r{^\w+/\w+/[0-9\.]+/\d{14}$}
    end

    it 'should load matchers correctly' do
      InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
      svc.has_standalone_topology?.must_equal true
      svc.has_leader_follower_topology?.must_equal false
      svc.updated_by_none?.must_equal true
      svc.updated_by_rolling?.must_equal false
      svc.updated_at_once?.must_equal false
    end
  end

  #==========================================================================#
  #                   Properties & Matchers - CLI mode
  #==========================================================================#
  describe 'when testing properties and matchers via the cli' do
    let(:fixture) do
      {
        cli: {
          cmd: 'svc status core/httpd',
          stdout_file: 'svc-status-single.cli.txt',
          exit_status: 0,
        },
      }
    end
    let(:svc) { HabitatService.new(origin: 'core', name: 'httpd') }

    it 'should load properties correctly' do
      InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
      svc.version.must_equal '2.4.35'
      svc.release.must_equal '20190307151146'
      svc.dependency_names.must_be_kind_of Array
      svc.dependency_names.must_be_empty # Not loadable via CLI
      svc.dependency_ids.must_be_kind_of Array
      svc.dependency_ids.must_be_empty # Not loadable via CLI
      svc.pkg_id.must_match %r{^\w+/\w+/[0-9\.]+/\d{14}$}
    end

    it 'should load matchers correctly' do
      InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
      svc.has_standalone_topology?.must_equal true
      svc.has_leader_follower_topology?.must_equal false
      svc.updated_by_none?.must_equal false # Not loadable via CLI
      svc.updated_by_rolling?.must_equal false
      svc.updated_at_once?.must_equal false
    end
  end
end

# rubocop:enable Metrics/BlockLength
