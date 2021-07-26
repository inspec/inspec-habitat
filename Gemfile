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
  gem "pry", "~> 0.14.0"
  gem "rake", "~> 13.0"
  gem "chefstyle", "2.0.7"
end

group :inspec do
  gem "inspec-bin", "~> 4.7"
end
