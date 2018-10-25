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

```
describe habitat_service(origin: 'core', name: 'httpd') do
  it                     { should exist }
  its('version')         { should eq '2.4.35'}
  its('topology')        { should eq 'standalone' }
  its('update_strategy') { should eq 'none' }
end
```

## Resource Documentation

TODO: List individual pages of resource documentation


## Contributing

If you'd like to contribute to this project please see [Contributing
Rules](CONTRIBUTING.md). The following instructions will help you get your
development environment setup to run integration tests.


### Getting Started

TODO: Write getting started


### Rake commands

TODO: Document rake commands for this project


### Development

Habitat CLI, the Habitat Supervisor, and a sample nginx application have been
provided in a kitchen VM. To start these run `kitchen converge`. The sample
application will be available on the host at port 8080. Habitat `http-gateway`
and `ctl-gateway` are available on ports 9631 and 9632.


### Testing

Tests are located in `test/integration/inspec-habitat` and may be run using
`kitchen verify`.
