control 'habitat_services' do
  # Properties check
  describe habitat_services do
    it                     { should exist }
    its('count') { should eq 2 }
    its('topologies')      { should eq ['standalone'] }
    its('update_strategies') { should eq ['none'] }
    its('dependency_names') { should include 'core/pcre' }
    its('dependency_names') { should_not include 'core/gcc' }
    its('names') { should include 'httpd'}
    its('names') { should include 'memcached'}
  end

  # Filtering
  describe habitat_services.where(name: 'httpd') do
    its('count') { should cmp 1 }
  end
  describe habitat_services.where { release >= '20181231000000'} do
    its('count') { should cmp 2 }
  end
end
