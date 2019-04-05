require_relative './unit_helper'
require_relative '../../libraries/habitat_packages'

# rubocop:disable Metrics/BlockLength
describe HabitatPackages do
  let(:unit_test_path) { File.expand_path(File.join('test', 'unit')) }
  let(:unit_fixture_path) { File.join(unit_test_path, 'fixtures') }

  extend InspecHabitat::UnitTestHelper

  check_definition(klass: HabitatPackages, name: 'habitat_packages')

  #==========================================================================#
  #                           Seek / Miss
  #==========================================================================#

  describe 'when seeking resources' do
    describe 'when using the api' do
      it 'should never find anything' do
        fixture = {}
        InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

        obj = HabitatPackages.new # No exception
        obj.wont_be_nil
        obj.exists?.must_equal false
        obj.count.must_equal 0
      end
    end

    describe 'when resources are locatable' do
      it 'should be found via the cli' do
        fixture = {
          cli: {
            cmd: 'pkg list --all',
            stdout_file: 'pkg-list-all.cli.txt',
            exit_status: 0,
          },
        }
        InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

        obj = HabitatPackages.new # No exception
        obj.wont_be_nil
        obj.exists?.must_equal true
        obj.count.must_equal 46
      end
    end

    describe 'when no resources exist' do
      it 'should not be found with via the cli' do
        fixture = {
          cli: {
            cmd: 'pkg list --all',
            stderr_file: 'pkg-list-miss.cli.txt',
            exit_status: 0,
          },
        }
        InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

        obj = HabitatPackages.new # No exception
        obj.wont_be_nil
        obj.exists?.wont_equal true
        obj.count.must_equal 0
      end
    end
  end

  #==========================================================================#
  #                         Filter Criteria
  #==========================================================================#
  describe 'when testing properties and matchers via the cli' do
    let(:fixture) do
      {
        cli: {
          cmd: 'pkg list --all',
          stdout_file: 'pkg-list-all.cli.txt',
          exit_status: 0,
        },
      }
    end
    let(:pkgs) { HabitatPackages.new }

    it 'should filter correctly' do
      InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
      pkgs.where { origin == 'core' }.count.must_equal 46
      pkgs.where { name == 'httpd' }.count.must_equal 1
      pkgs.where { release > '20190305231155' }.count.must_equal 6
      pkgs.where { version == '1.5.12' }.count.must_equal 1
    end

    it 'should expose criteria as properties correctly' do
      InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
      pkgs.origins.must_equal ['core']
      pkgs.names.must_include 'httpd'
      pkgs.releases.sort.must_include '20190305231154'
      pkgs.versions.sort.must_include '1.5.12'
    end

    it 'should expose non-filter properties correctly' do
      InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
      hpp = pkgs.habitat_package_params
      hpp.must_be_kind_of Array
      hpp.first.must_be_kind_of Hash
      hpp.first.keys.must_include :origin
      hpp.first.keys.must_include :name
      hpp.first.keys.must_include :version
      hpp.first.keys.must_include :release
    end
  end

  #==========================================================================#
  #                         Non-Filter Properties
  #==========================================================================#

end
# rubocop:enable Metrics/BlockLength
