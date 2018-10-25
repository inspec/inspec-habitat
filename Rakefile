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

desc 'Linting tasks'
task lint: [:rubocop, :syntax]

task default: :lint
