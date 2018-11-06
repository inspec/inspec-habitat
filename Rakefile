# frozen_string_literal: true

require 'bundler'
require 'bundler/gem_helper'
require 'rake/testtask'
require 'rubocop/rake_task'
require 'open3'

RuboCop::RakeTask.new

desc 'Ruby syntax check'
task :syntax do
  files = %w{Gemfile Rakefile} + Dir['./**/*.rb']

  files.each do |file|
    sh('ruby', '-c', file) do |ok, res|
      next if ok

      puts 'Syntax check FAILED'
      exit res.exitstatus
    end
  end
end

namespace :test do
  desc 'Integration Tests'
  task :integration, [:controls] do |_t, args|
    cmd = %w{ bundle exec inspec exec test/integration/verify
              --reporter progress -t habitat://localhost:9631 }

    cmd += ['--controls', args[:controls], *args.extras] if args[:controls]

    sh(*cmd)
  end
end

desc 'Linting tasks'
task lint: [:rubocop, :syntax]

task default: :lint
