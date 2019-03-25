control 'habitat_service' do
  describe habitat_service(origin: 'core', name: 'httpd') do
    it                     { should exist }
    its('version')         { should cmp >= '2.3.45' }
    its('dependency_names.size')       { should eq 28 }
    its('pkg_id')          { should match %r(core\/httpd\/\d+.\d+\.\d+\/\d{14}$) }
    its('release')         { should cmp >= '20180608050617' }
    it { should have_standalone_topology }
    it { should be_updated_by_none }
  end
end
