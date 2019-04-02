# InSpec Habitat Resource Pack

[![Build Status](https://travis-ci.org/inspec/inspec-habitat.svg?branch=master)](https://travis-ci.org/inspec/inspec-habitat)


## Prerequisites

* InSpec v3.8 or later TODO: determine version that includes train-habitat

## Use the Resources

Since this is an InSpec resource pack, it only defines InSpec resources. To use
these resources in your own controls you should create your own profile:

### Create a new profile

```
$ inspec init profile my-profile
```
Example inspec.yml:
```
name: my-profile
title: My own Hab profile
version: 0.1.0
inspec_version: '>= 3.8.0'
depends:
  - name: inspec-habitat
    url: https://github.com/inspec/inspec-habitat/archive/master.tar.gz
```

## Examples

```
describe habitat_service(origin: 'core', name: 'httpd') do
  it                     { should exist }
  its('version')         { should eq '2.4.35'}
  its('topology')        { should eq 'standalone' }
  its('update_strategy') { should eq 'none' }
end
```


## Resource Documentation

Resource documentation is located at the [main InSpec docs website](https://www.inspec.io/docs/reference/resources/#habitat-resources) as well as in the [source code docs directory](https://github.com/inspec/inspec-habitat/tree/master/docs/resources)


## Contributing

If you'd like to contribute to this project please see [Contributing
Rules](CONTRIBUTING.md). The following instructions will help you get your
development environment setup to run integration tests.

### Prerequisites for All Testing

  1. Ruby 2.3 or later
  2. Bundler
  3. Run `bundle install`.

### Prerequisites for Integration Testing

  1. Vagrant
  2. VirtualBox, or configure your Vagrant installation to use your favorite provider.

### Rake commands

#### Ruby syntax check

Runs the Ruby syntax checker against code in this repository.

```
$ bundle exec rake syntax
```

#### Rubocop

Runs Rubocop syntax checker against code in this repository.

```
$ bundle exec rake rubocop
```

#### Lint

Runs Rubocop and syntax checks against code in this repository. This is the default Rake task.

```
$ bundle exec rake lint
```

#### Run Unit Tests

Uses Minitest to test features of the code while simulating the responses of a Habitat installation.

```
$ bundle exec rake test:unit
```

#### Run Integration Tests

Runs integration tests against a running Habitat installation in a running Vagrant machine.

```
# To spin up the VM, run tests, and destroy the VM in one command
$ bundle exec rake test:integration
# See bundle exec rake -aT for other variations
```

### Development

Habitat CLI, the Habitat Supervisor, and a sample httpd/memcached application have been
provided in a Vagrant VM. The sample application will be available on the host at port 7080. Habitat `http-gateway` and `ctl-gateway` are available on ports 7631 and 7632.

### Testing

Tests are located in `test/integration/` and may be run using
`rake test:integration`.
