control 'habitat_package' do
  describe habitat_package(origin: 'core', name: 'httpd') do
    it                     { should exist }
    its('version')         { should cmp >= '2.3.45' }
    its('release')         { should cmp >= '20180608050617' }
    its('installation_path') { should match %r(/hab/pkgs/core/httpd/\d+\.\d+\.\d+/\d{14}) }
    its('dependency_ids.count') { should cmp >= 28 }
    its('dependency_names') { should include 'core/glibc' }
  end
end
