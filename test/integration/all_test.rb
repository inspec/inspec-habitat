require_relative './integration_helper'

describe 'All integration tests' do
  include InspecHabitat::IntegrationTestHelpers

  it 'should all pass' do
<<<<<<< HEAD
    result = run_inspec_againt_hab('test-profile')
    result.stderr.must_be_empty
=======
    result = run_inspec_againt_hab(File.join(int_test_path, 'test-profile'))
    result.payload.stderr_without_deprecations.must_be_empty
>>>>>>> Linting
    result.must_have_all_controls_passing
  end
end
