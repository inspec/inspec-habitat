require "minitest/autorun"
require "minitest/spec"

require "train"

require "byebug"
require "json"
require "tmpdir"
require "forwardable"

class Module
  include Minitest::Spec::DSL
end

module InspecHabitat
  class IntTestRunResult
    attr_reader :train_result
    attr_reader :payload

    extend Forwardable
    def_delegator :train_result, :stdout
    def_delegator :train_result, :stderr
    def_delegator :train_result, :exit_status

    def initialize(train_result)
      @train_result = train_result
      @payload = OpenStruct.new
    end

    def must_have_all_controls_passing
      if payload.json == {}
        payload.json_error.must_be_empty # won't be, this just clearly fails the test
        return false
      end
      # Strategy: assemble an array of tests that failed or skipped, and insist it is empty
      # result.payload.json['profiles'][0]['controls'][0]['results'][0]['status']
      failed_tests = []
      payload.json["profiles"].each do |profile_struct|
        profile_name = profile_struct["name"]
        profile_struct["controls"].each do |control_struct|
          control_name = control_struct["id"]
          control_struct["results"].compact.each do |test_struct|
            test_desc = test_struct["code_desc"]
            if test_struct["status"] != "passed"
              failed_tests << "#{profile_name}/#{control_name}/#{test_desc}"
            end
          end
        end
      end

      failed_tests.must_be_empty
    end
  end

  module IntegrationTestHelpers
    let(:pack_repo_path) { File.expand_path(File.join(__FILE__, "..", "..", "..")) }
    let(:int_test_path) { File.join(pack_repo_path, "test", "integration") }
    let(:inspec_exec) { "bundle exec inspec exec " }

    LOCAL_TRAIN_CONNECTION = Train.create("local", command_runner: :generic).connection

    def run_inspec_againt_hab(profile_name, _opts = {})
      invocation = inspec_exec
      invocation += " " + File.join(int_test_path, profile_name) + " "
      invocation += " -t habitat://int_test "
      invocation += " --no-create-lockfile "
      invocation += " --config " + File.join(int_test_path, "config.json")
      invocation += " --reporter json "

      result = IntTestRunResult.new(LOCAL_TRAIN_CONNECTION.run_command(invocation))
      result.payload.invocation = invocation

      begin
        result.payload.json = JSON.parse(result.stdout)
      rescue JSON::ParserError => e
        result.payload.json = {}
        result.payload.json_error = e
      end

      result
    end
  end
end
