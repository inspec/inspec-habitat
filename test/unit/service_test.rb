require_relative './unit_helper'
require_relative '../../libraries/habitat_service'

# rubocop:disable Metrics/BlockLength
describe HabitatService do # rubocop:disable Metrics/BlockLength
  let(:unit_test_path) { File.expand_path(File.join('test', 'unit')) }
  let(:unit_fixture_path) { File.join(unit_test_path, 'fixtures') }

  extend InspecHabitat::UnitTestHelper

  check_definition(klass: HabitatService, name: 'habitat_service')

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
  # describe 'when loading a resource' do
  #   it 'should have correct properties'
  #   it 'should have correct matchers'
  # end
end

# rubocop:enable Metrics/BlockLength
