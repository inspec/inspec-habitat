control "habitat_packages" do
  # Properties check
  describe habitat_packages do
    it { should exist }
    its("count") { should be >= 37 }
    its("names") { should include "httpd" }
    its("names") { should include "memcached" }
  end

  # Filtering
  describe habitat_packages.where(name: "httpd") do
    its("count") { should cmp 1 }
  end
  describe habitat_packages.where { release >= "20181231000000" } do # rubocop:disable Lint/AmbiguousBlockAssociation
    its("count") { should >= 2 }
  end
end
