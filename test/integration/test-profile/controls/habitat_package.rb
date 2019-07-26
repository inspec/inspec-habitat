control "habitat_package" do
  describe habitat_package(origin: "core", name: "httpd") do
    it                     { should exist }
    its("version")         { should cmp >= "2.3.45" }
    its("release")         { should cmp >= "20180608050617" }
  end
end
