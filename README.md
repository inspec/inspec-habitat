# InSpec Habitat Resource Pack

[![Build Status](https://travis-ci.org/inspec/inspec-habitat.svg?branch=master)](https://travis-ci.org/inspec/inspec-habitat)

TODO: Write project summary


## Prerequisites

* Ruby
* Bundler installed


## Use the Resources

Since this is an InSpec resource pack, it only defines InSpec resources. To use
these resources in your own controls you should create your own profile:


#### Create a new profile

```
$ inspec init profile my-profile
```
Example inspec.yml:
```
name: my-profile
title: My own Oneview profile
version: 0.1.0
inspec_version: '>= 2.2.7'
depends:
  - name: inspec-habitat
    url: https://github.com/inspec/inspec-habitat/archive/master.tar.gz
```

## Examples

TODO: Show examples of use


## Resource Documentation

TODO: List individual pages of resource documentation


## Development

If you'd like to contribute to this project please see [Contributing
Rules](CONTRIBUTING.md). The following instructions will help you get your
development environment setup to run integration tests.


### Getting Started

TODO: Write getting started


### Rake commands

TODO: Document rake commands for this project


### Development

Habitat and the Habitat Supervisor have been provided in a kitchen VM. To start
simply run `kitchen converge`.

### Testing

Tests are located in `test/integration/inspec-habitat` and may be run using `kitchen verify`.
