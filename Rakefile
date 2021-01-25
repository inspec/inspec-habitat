# frozen_string_literal: true

require "bundler"
require "bundler/gem_helper"
require "rake/testtask"
require "chefstyle"
require "rubocop/rake_task"
require "open3"

RuboCop::RakeTask.new

desc "Ruby syntax check"
task :syntax do
  files = %w{Gemfile Rakefile} + Dir["./**/*.rb"]

  files.each do |file|
    sh("ruby", "-c", file) do |ok, res|
      next if ok

      puts "Syntax check FAILED"
      exit res.exitstatus
    end
  end
end

namespace(:test) do
  # desc 'Run all integration tests'
  # task integration: %i(integration:sup_start integration:api_actual integration:cli_ssh_actual integration:sup_shutdown)

  desc "Unit tests"
  Rake::TestTask.new(:unit) do |t|
    t.libs.concat %w{test/unit libraries}
    t.test_files = FileList[
      "test/unit/*_test.rb",
    ]
    t.verbose = true
    t.warning = false
  end

  desc "integration tests"
  task integration: %i{integration:sup_start integration:integration_actual integration:sup_shutdown}
  Rake::TestTask.new(:integration_actual) do |t|
    t.libs.concat %w{test/integration}
    t.test_files = FileList[
      "test/integration/*_test.rb",
    ]
    t.verbose = true
    t.warning = false
  end

  namespace(:integration) do
    {
      # A hidden task to start a vagrant vm with a running supervisor
      # It will expose SSH, httpd, and hab-sup
      sup_start: "vagrant up",
      # A hidden task to shutdown the vagrant vm with the supervisor
      sup_shutdown: "vagrant destroy -f",
      # Utility for debugging - Login to to the supervisor
      sup_login: "vagrant ssh",
    }.each do |task_name, cmd|
      task task_name do
        Dir.chdir("test/integration/sup-fixture") do
          sh cmd
        end
      end
    end
  end
end

desc "Linting tasks"
task lint: %i{rubocop syntax}

task default: %i{lint test:unit}
