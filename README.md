# InSpec Habitat Resource Pack

* **Project State: Active**
* **Issues Response SLA: 3 business days**
* **Pull Request Response SLA: 3 business days**

For more information on project states and SLAs, see [this documentation](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md).

[![Build Status](https://travis-ci.org/inspec/inspec-habitat.svg?branch=master)](https://travis-ci.org/inspec/inspec-habitat)


## Prerequisites

* InSpec v4.7.3 or later
* A running Habitat Supervisor which you can access either via SSH, the HTTP API, or (ideally), both.

### Configuring InSpec to Reach Habitat

_Getting an `unsupported platform' error? This section will help!_

`inspec-habitat` uses whatever method is available to query Habitat to obtain information, either from the the `hab` CLI command (via SSH) or the HTTP API gateway. Because of this dual nature, the number of possible connection options is large; it is recommended to place your connection options in a configuration file and then reference them by name. For example, if you place this JSON code in your `~/.inspec/config.json`:

```json
{
  "file_version": "1.1",
  "credentials": {
    "habitat": {
      "dev-hab": {
        "api_url": "http://dev-hab.my-corp.io",
        "cli_ssh_host": "dev-hab.my-corp.io"
      }
    }
  }
}
```

You can then execute the profile 'someprofile' using the command line:

```
you@yourhost $ inspec exec someprofile -t habitat://dev-hab
```

Notice that `dev-hab` is just the label for the set of configuration options. You may have as many sets of configuration options as you like.

Properly speaking, these options are being fed to the support library, `train-habitat`. It supports many additional options, including authentication tokens for the API server and SSH options. Please see [Using train-habitat from Ruby](https://github.com/inspec/train-habitat#using-train-habitat-from-ruby) for further details.

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
inspec_version: '>= 4.7.3'
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
