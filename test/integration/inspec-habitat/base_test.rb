# # encoding: utf-8

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe directory('/hab/pkgs/core/hab-sup') do
  it { should exist }
end
