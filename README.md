# InSpec Habitat Resource Pack

* **Project State: Active** (but EXPERIMENTAL)
* **Issues Response SLA: 3 business days**
* **Pull Request Response SLA: 3 business days**

For more information on project states and SLAs, see [this documentation](https://github.com/chef/chef-oss-practices/blob/master/repo-management/repo-states.md).

[![Build Status](https://travis-ci.org/inspec/inspec-habitat.svg?branch=master)](https://travis-ci.org/inspec/inspec-habitat)


## Notice - Experimental Project

This resource pack is in the early stages of research and development. Functionality may be defective, incomplete, or be withdrawn in the future. If you are interested in helping this project mature, please join the conversation or contribute code at the [inspec-habitat project](https://github.com/inspec/inspec-habitat).

## Prerequisites

* InSpec v4.7.3 or later
* A running Habitat Supervisor, which you can access via SSH, the HTTP API, or (ideally) both.

### Configuring InSpec to Reach Habitat

_Getting an `unsupported platform' error? This section will help!_

#### Using the `--target` option is required

To connect to habitat, you _must_ use the `-t` option (`--target`) to specify that you are connecting to a `habitat://` type target. If you omit this, InSpec will attempt to connect to the local system, and the platform will not match.

So, all of your invocations should look like this:

```
you@somehost $ inspec exec someprofile --target habitat://my-config
```

What does `my-config` refer to? [Keep reading!](#defining-a-configuration-section)

#### Defining a configuration section

`inspec-habitat` uses whatever available method to query Habitat to obtain information, either from the the `hab` CLI command (via SSH) or the HTTP API gateway. `inspec-habitat` uses the `hab` command line program to obtain certain information; currently it must use SSH to connect to the machine where `hab` is installed. Additionally, some information is only available via the Supervisor HTTP API.

Because of this dual nature, the number of possible connection options is large. It is recommended to place your connection options in a configuration file and then reference them using the `--target habitat://my-config` option format. For example, if you place this JSON code in your `~/.inspec/config.json`:

```json
{
  "file_version": "1.1",
  "credentials": {
    "habitat": {
      "my-config": {
        "api_url": "http://dev-hab.my-corp.io",
        "cli_ssh_host": "dev-hab.my-corp.io",
        "cli_ssh_user": "someuser",
        "cli_ssh_key_files": "~/.ssh/KEYNAME"
      }
    }
  }
}
```

Then InSpec will look up your configuration options under the `my-config` label. (Connection options details can be found [below](#connection-options-for-inspec-habitat).) With the `config.json` file established, you can then execute the profile 'someprofile' using the command line:

```
you@yourhost $ inspec exec someprofile -t habitat://my-config
```

Notice that `my-config` is the label for the set of configuration options. Within the target `habitat://my-config`, the schema `habitat://` is required to select the train-habitat driver, and then the `my-config` label selects the matching set of options from the configuration file. You may have as many sets of configuration options as you like - perhaps one for a development environment, one for production, etc.

#### Connection Options for inspec-habitat

Here are the most commonly used options for inspec-habitat. While it is possible to use inspec-habitat using only API or SSH access, the richest experience is obtained when both sets of options are provided.

This group of connection options deals with configuring access to the API server:

 * `api_url` - URL to the supervisor API. If no port is specified, 9631 is assumed. If api_url is omitted, it is assumed the API is not available.
 * `api_auth_token` - Bearer token for the supervisor API. If you configured your supervisor to expect a token, place it here.

This group of connection options deals with configuring access to a host via SSH, which has a hab binary that is local to the machine running the supervisor:

 * `cli_ssh_host` - IP or hostname of the machine to connect to. If omitted, it is assumed that the CLI interface is not available.
 * `cli_ssh_user` - Username to connect as. If omitted will use the OS user that the `inspec` process is running as.
 * `cli_ssh_key_files` - Array or single string. Paths or path to key files to use when authenticating via SSH.

Technically speaking, these connection options are being fed to the support library, `train-habitat`. `train-habitat` supports many additional options, especially for more obscure SSH options. Please see [Using train-habitat from Ruby](https://github.com/inspec/train-habitat#using-train-habitat-from-ruby) for further details.

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
