require_relative './unit_helper'
require_relative '../../libraries/habitat_services'

describe HabitatServices do # rubocop:disable Metrics/BlockLength
  let(:unit_test_path) { File.expand_path(File.join('test', 'unit')) }
  let(:unit_fixture_path) { File.join(unit_test_path, 'fixtures') }

  extend InspecHabitat::UnitTestHelper

  check_definition(klass: HabitatServices, name: 'habitat_services')

  #==========================================================================#
  #                           Seek / Miss
  #==========================================================================#

  describe 'when seeking resources' do
    describe 'when resources are locatable' do
      it 'should be found via the api' do
        fixture = {
          api: {
            path: '/services',
            body_file: 'services-multi.api.json',
            code: 200,
          },
        }
        InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

        obj = HabitatServices.new # No exception
        obj.wont_be_nil
        obj.exists?.must_equal true
        obj.count.must_equal 2
      end

      it 'should be found via the cli' do
        fixture = {
          cli: {
            cmd: 'svc status',
            stdout_file: 'svc-status-multi.cli.txt',
            exit_status: 0,
          },
        }
        InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

        obj = HabitatServices.new # No exception
        obj.wont_be_nil
        obj.exists?.must_equal true
        obj.count.must_equal 2
      end
    end

    describe 'when no resources exist' do
      it 'should be not found via the api' do
        fixture = {
          api: {
            path: '/services',
            body_file: 'services-none.api.json',
            code: 200,
          },
        }
        InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

        obj = HabitatServices.new # No exception
        obj.wont_be_nil
        obj.exists?.wont_equal true
        obj.count.must_equal 0
      end

      it 'should not be found with via the cli' do
        fixture = {
          cli: {
            cmd: 'svc status',
            stderr_file: 'svc-status-none.cli.txt',
            exit_status: 0,
          },
        }
        InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

        obj = HabitatServices.new # No exception
        obj.wont_be_nil
        obj.exists?.wont_equal true
        obj.count.must_equal 0
      end
    end
  end

  #==========================================================================#
  #                   Filter Criteria - API mode
  #==========================================================================#

  describe 'when testing filter criteria via the api' do
    let(:fixture) do
      {
        api: {
          path: '/services',
          body_file: 'services-multi.api.json',
          code: 200,
        },
      }
    end
    let(:svcs) { HabitatServices.new }

    it 'should filter correctly' do
      InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
      # TODO
    end

    it 'should expose criteria as porperties correctly' do
      InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
      # TODO
    end
  end

  #==========================================================================#
  #                   Filter Criteria - CLI mode
  #==========================================================================#
  describe 'when testing properties and matchers via the cli' do
    let(:fixture) do
      {
        cli: {
          cmd: 'svc status',
          stdout_file: 'svc-status-multi.cli.txt',
          exit_status: 0,
        },
      }
    end
    let(:svcs) { HabitatServices.new }

    it 'should filter correctly' do
      InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
      # TODO
    end

    it 'should expose criteria as porperties correctly' do
      InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
      # TODO
    end
  end
end
# rubocop:enable Metrics/BlockLength
