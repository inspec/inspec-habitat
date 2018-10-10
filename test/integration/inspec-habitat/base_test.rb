# # encoding: utf-8

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe directory('/hab/pkgs/core/hab-sup') do
  it { should exist }
end

describe directory('/hab/svc/nginx/data') do
  it { should exist }
end

describe file('/hab/svc/nginx/data/index.html') do
  its('content') { should match %r(Hello World) }
end
