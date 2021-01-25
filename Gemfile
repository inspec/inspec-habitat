source "https://rubygems.org"

gem "bundle"

if Gem.ruby_version.to_s.start_with?("2.5")
  # 16.7.23 required ruby 2.6+
  gem "chef-utils", "< 16.7.23" # TODO: remove when we drop ruby 2.5
end

group :development do
  gem "byebug", "~> 11.0"
  gem "github_changelog_generator"
  gem "m", "~> 1.5"
  gem "minitest", "~> 5.11"
  gem "mocha", "~> 1.8"
  gem "pry", "~> 0.13.1"
  gem "rake", "~> 12.3", ">= 12.3.1"
  gem "chefstyle", "1.5.9"
end

group :inspec do
  gem "inspec-bin", "~> 4.7"
end
