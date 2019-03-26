control 'habitat_service' do
  describe habitat_service(origin: 'core', name: 'nginx') do
    it                     { should exist }
    its('version')         { should cmp >= '1.15.5' }
    its('topology')        { should eq 'standalone' }
    its('update_strategy') { should eq 'none' }
    its('deps.size')       { should eq 10 }
    its('pkg_id')          { should match %r(core\/nginx\/\d+.\d+\.\d+\/\d{14}$) }
    its('release')         { should cmp >= '20180608050617' }
  end
end
