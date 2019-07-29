require_relative "./unit_helper"
require_relative "../../libraries/habitat_services"

# rubocop:disable Metrics/BlockLength
describe HabitatServices do
  let(:unit_test_path) { File.expand_path(File.join("test", "unit")) }
  let(:unit_fixture_path) { File.join(unit_test_path, "fixtures") }

  extend InspecHabitat::UnitTestHelper

  check_definition(klass: HabitatServices, name: "habitat_services")

  #==========================================================================#
  #                           Seek / Miss
  #==========================================================================#

  describe "when seeking resources" do
    describe "when resources are locatable" do
      it "should be found via the api" do
        fixture = {
          api: {
            path: "/services",
            body_file: "services-multi.api.json",
            code: 200,
          },
        }
        InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

        obj = HabitatServices.new # No exception
        obj.wont_be_nil
        obj.exists?.must_equal true
        obj.count.must_equal 2
      end

      it "should be found via the cli" do
        fixture = {
          cli: {
            cmd: "svc status",
            stdout_file: "svc-status-multi.cli.txt",
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

    describe "when no resources exist" do
      it "should be not found via the api" do
        fixture = {
          api: {
            path: "/services",
            body_file: "services-none.api.json",
            code: 200,
          },
        }
        InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)

        obj = HabitatServices.new # No exception
        obj.wont_be_nil
        obj.exists?.wont_equal true
        obj.count.must_equal 0
      end

      it "should not be found with via the cli" do
        fixture = {
          cli: {
            cmd: "svc status",
            stderr_file: "svc-status-none.cli.txt",
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

  describe "when testing filter criteria via the api" do
    let(:fixture) do
      {
        api: {
          path: "/services",
          body_file: "services-multi.api.json",
          code: 200,
        },
      }
    end
    let(:svcs) { HabitatServices.new }

    it "should filter correctly" do
      InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
      svcs.where { origin == "core" }.count.must_equal 2
      svcs.where { name == "httpd" }.count.must_equal 1
      svcs.where { dependency_names.include? "core/pcre" }.names.must_equal ["httpd"]
      svcs.where { topology == "standalone" }.count.must_equal 2
      svcs.where { update_strategy == "none" }.count.must_equal 2
      svcs.where { release > "20190305231155" }.count.must_equal 1
      svcs.where { version == "1.5.12" }.count.must_equal 1
    end

    it "should expose criteria as properties correctly" do
      InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
      svcs.origins.must_equal ["core"]
      svcs.names.sort.must_equal %w{httpd memcached}
      svcs.dependency_names.must_include "core/pcre"
      svcs.dependency_names.wont_include "core/gcc"
      svcs.topologies.must_equal ["standalone"]
      svcs.update_strategies.must_equal ["none"]
      svcs.releases.sort.must_equal %w{20190305231154 20190307151146}
      svcs.versions.sort.must_equal ["1.5.12", "2.4.35"]
    end
  end

  #==========================================================================#
  #                   Filter Criteria - CLI mode
  #==========================================================================#
  describe "when testing properties and matchers via the cli" do
    let(:fixture) do
      {
        cli: {
          cmd: "svc status",
          stdout_file: "svc-status-multi.cli.txt",
          exit_status: 0,
        },
      }
    end
    let(:svcs) { HabitatServices.new }

    it "should filter correctly" do
      InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
      svcs.where { origin == "core" }.count.must_equal 2
      svcs.where { name == "httpd" }.count.must_equal 1
      svcs.where { dependency_names.include? "core/pcre" }.names.must_equal [] # Not available by CLI
      svcs.where { topology == "standalone" }.count.must_equal 2
      svcs.where { update_strategy == "none" }.count.must_equal 0 # Not available by CLI
      svcs.where { release > "20190305231155" }.count.must_equal 1
      svcs.where { version == "1.5.12" }.count.must_equal 1
    end

    it "should expose criteria as properties correctly" do
      InspecHabitat::UnitTestHelper.mock_inspec_context_object(self, fixture)
      svcs.origins.must_equal ["core"]
      svcs.names.sort.must_equal %w{httpd memcached}
      svcs.dependency_names.must_be_empty # Not available by CLI
      svcs.topologies.must_equal ["standalone"]
      svcs.update_strategies.must_be_empty # Not available by CLI
      svcs.releases.sort.must_equal %w{20190305231154 20190307151146}
      svcs.versions.sort.must_equal ["1.5.12", "2.4.35"]
    end
  end
end
# rubocop:enable Metrics/BlockLength
