require_relative "./integration_helper"

describe "All integration tests" do
  include InspecHabitat::IntegrationTestHelpers

  it "should all pass" do
    result = run_inspec_againt_hab("test-profile")
    result.stderr.must_be_empty
    result.must_have_all_controls_passing
  end
end
