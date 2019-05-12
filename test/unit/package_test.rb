require_relative './unit_helper'
require_relative '../../libraries/habitat_package'

# rubocop:disable Metrics/BlockLength
describe HabitatPackage do
  let(:unit_test_path) { File.expand_path(File.join('test', 'unit')) }
  let(:unit_fixture_path) { File.join(unit_test_path, 'fixtures') }

  extend InspecHabitat::UnitTestHelper

  check_definition(klass: HabitatPackage, name: 'habitat_package')

  #==========================================================================#
  #                             Resource Params
  #==========================================================================#

  describe 'when seeking the resource' do

    #------------------------------ Via API ---------------------------------#
    describe 'when trying to use the API' do
      {
        string: 'core/httpd',
        hash: { origin: 'core', name: 'httpd' },
      }.each do |params_mode, params|
        it "should never find the resource in #{params_mode} mode" do
          fixture = {}
          InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

          obj = HabitatPackage.new(params) # No exception
          obj.wont_be_nil
          obj.exists?.wont_equal true
        end
      end
    end

    #------------------------------ Unique ---------------------------------#
    describe 'when the resource is uniquely locatable' do
      {
        string: 'core/httpd',
        hash: { origin: 'core', name: 'httpd' },
      }.each do |params_mode, params|
        it "should be found via the cli in #{params_mode} mode" do
          fixture = {
            cli: {
              cmd: 'pkg list core/httpd',
              stdout_file: 'pkg-list-single.cli.txt',
              exit_status: 0,
            },
          }
          InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

          obj = HabitatPackage.new(params) # No exception
          obj.wont_be_nil
          obj.exists?.must_equal true
        end
      end
    end

    #------------------------------ Miss ---------------------------------#
    describe 'when the resource does not exist' do
      {
        string: 'core/nosuchpkg',
        hash: { origin: 'core', name: 'nosuchpkg' },
      }.each do |params_mode, params|
        it "should not be found via the cli in #{params_mode} mode" do
          fixture = {
            cli: {
              cmd: 'pkg list core/nosuchpkg',
              stdout_file: 'pkg-list-miss.cli.txt',
              exit_status: 0, # Note: inconsistent with hav svc
            },
          }
          InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

          obj = HabitatPackage.new(params) # No exception
          obj.wont_be_nil
          obj.exists?.wont_equal true
        end
      end
    end

    #---------------------------- Multi-Version ---------------------------------#
    describe 'when the resource exists in multiple versions' do
      {
        string: 'core/glibc',
        hash: { origin: 'core', name: 'glibc' },
      }.each do |params_mode, params|
        it "should be found via the cli in #{params_mode} mode" do
          fixture = {
            cli: {
              cmd: 'pkg list core/glibc',
              stdout_file: 'pkg-list-multi-versions.cli.txt',
              exit_status: 0,
            },
          }
          InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

          ex = assert_raises(ArgumentError) { HabitatPackage.new(params) }
          ex.message.must_include 'Multiple package versions/releases matched'
          ex.message.must_include 'more specific'
        end
      end
    end

    describe 'when the resource exists in multiple versions and you specify a version' do
      {
        string: 'core/glibc/2.22',
        hash: { origin: 'core', name: 'glibc', version: '2.22' },
      }.each do |params_mode, params|
        it "should be found via the cli in #{params_mode} mode" do
          fixture = {
            cli: {
              cmd: 'pkg list core/glibc/2.22',
              stdout_file: 'pkg-list-single-specific-version.cli.txt',
              exit_status: 0,
            },
          }
          InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

          obj = HabitatPackage.new(params) # No exception
          obj.wont_be_nil
          obj.exists?.must_equal true
          obj.version.must_equal '2.22'
          obj.release.must_equal '20160612063629'
        end
      end
    end

    #---------------------------- Multi-Release ---------------------------------#
    describe 'when the resource exists in multiple releases' do
      {
        string: 'core/libiconv',
        hash: { origin: 'core', name: 'libiconv' },
      }.each do |params_mode, params|
        it "should be found via the cli in #{params_mode} mode" do
          fixture = {
            cli: {
              cmd: 'pkg list core/libiconv',
              stdout_file: 'pkg-list-multi-releases.cli.txt',
              exit_status: 0,
            },
          }
          InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

          ex = assert_raises(ArgumentError) { HabitatPackage.new(params) }
          ex.message.must_include 'Multiple package versions/releases matched'
          ex.message.must_include 'more specific'
        end
      end
    end

    describe 'when the resource exists in multiple releases and you specify a release' do
      {
        string: 'core/libiconv/1.14/20180608141251',
        hash: { origin: 'core', name: 'libiconv', version: '1.14', release: '20180608141251' },
      }.each do |params_mode, params|
        it "should be found via the cli in #{params_mode} mode" do
          fixture = {
            cli: {
              cmd: 'pkg list core/libiconv/1.14/20180608141251',
              stdout_file: 'pkg-list-single-specific-release.cli.txt', # TODO
              exit_status: 0,
            },
          }
          InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

          obj = HabitatPackage.new(params) # No exception
          obj.wont_be_nil
          obj.exists?.must_equal true
          obj.version.must_equal '1.14'
          obj.release.must_equal '20180608141251'
        end
      end
    end
  end

  #==========================================================================#
  #                             Properties
  #==========================================================================#

  describe 'properties' do
    describe 'installation_path' do
      it 'should be correct' do
        fixture = {
          cli: [
            { cmd: 'pkg list core/hab',   stdout_file: 'pkg-list-hab.cli.txt', },
            { cmd: regexp_matches(/pkg env core\/hab/),    stdout_file: 'pkg-env-hab.cli.txt',  },
            { cmd: 'pkg list core/httpd', stdout_file: 'pkg-list-single.cli.txt',  },
          ],
        }
        InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
        pkg = HabitatPackage.new('core/httpd')
        pkg.installation_path.must_equal('/hab/pkgs/core/httpd/2.4.35/20190307151146')
      end
    end

    describe 'dependency ids and names' do
      it 'should be correct' do
        fixture = {
          cli: [
            { cmd: 'pkg list core/hab',   stdout_file: 'pkg-list-hab.cli.txt', },
            { cmd: regexp_matches(/pkg env core\/hab/),    stdout_file: 'pkg-env-hab.cli.txt',  },
            { cmd: 'pkg list core/httpd', stdout_file: 'pkg-list-single.cli.txt',  },
          ],
          general_cli: [
            { cmd: 'cat /hab/pkgs/core/httpd/2.4.35/20190307151146/TDEPS', stdout_file: 'cat-httpd-tdeps.cli.txt' }
          ]
        }
        InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
        pkg = HabitatPackage.new('core/httpd')
        dep_ids = pkg.dependency_ids
        dep_ids.count.must_equal 28
        dep_ids.must_include 'core/glibc/2.27/20190115002733'

        dep_names = pkg.dependency_names
        dep_names.count.must_equal dep_ids.count
        dep_names.must_include 'core/glibc'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
