+++
title = "About the Chef InSpec Habitat resource pack"

draft = false

linkTitle = "Habitat resource pack"
summary = "Chef InSpec resources for auditing Habitat packages and services."

[cascade]
  [cascade.params]
    platform = "habitat"

[menu.habitat]
    title = "About Habitat resources"
    identifier = "inspec/resources/habitat/About"
    parent = "inspec/resources/habitat"
    weight = 10
+++

The Chef InSpec Habitat resources allow you to audit and test Chef Habitat packages and services in your infrastructure. You can verify package installations, check service configurations, and validate the operational state of your Habitat-managed applications.

{{< note >}}

This resource pack is in the early stages of development. Functionality may be defective, incomplete, or be withdrawn in the future. If you are interested in helping this project mature, please join the conversation or contribute code at the [inspec-habitat project](https://github.com/inspec/inspec-habitat).

{{< /note >}}

## Prerequisites

- Chef InSpec v4.7.3 or later
- A running Habitat Supervisor that you can access using SSH, the HTTP API, or (ideally) both.

## Connecting to Habitat

The `inspec-habitat` resources connect to Habitat using two methods:

- **SSH connection with `hab` CLI**: Required for package information and some service data
- **HTTP API connection**: Provides access to the Habitat Supervisor API for real-time service status

For the most comprehensive testing capabilities, configure both connection methods. If only one method is available, InSpec will use the available connection and skip tests that require the unavailable method.

### Configure Habitat connections

Configure your Habitat connections in the [InSpec configuration file](https://docs.chef.io/inspec/config/) at `~/.inspec/config.json`. You can create multiple connection profiles for different environments (for example, development, staging, and production).

Use the following format in your configuration file:

```json
{
  "file_version": "1.1",
  "credentials": {
    "habitat": {
      "<CONFIG_NAME>": {
        "api_url": "http://dev-hab.example.com",
        "api_auth_token": "<TOKEN>",
        "cli_ssh_host": "dev-hab.example.com",
        "cli_ssh_user": "username",
        "cli_ssh_key_files": "~/.ssh/KEYNAME"
      }
    }
  }
}
```

Habitat Supervisor API options:

`api_url`
: The URL to the Habitat Supervisor API. InSpec defaults to port 9631 if a port isn't specified.

`api_auth_token`
: The bearer token for API authentication. This is required only if your Habitat Supervisor is configured to expect a token.

SSH connection options:

`cli_ssh_host`
: The IP or hostname of the machine to connect to. If omitted, it is assumed that the CLI interface isn't available.

`cli_ssh_user`
: The SSH username. It defaults to the current OS user if a value isn't specified.

`cli_ssh_key_files`
: The SSH key file paths for authentication. This can be a single string or an array of paths.

{{< note >}}

The `train-habitat` driver has many additional connection options. For further details, see the [`train-habitat` documentation](https://github.com/inspec/train-habitat#using-train-habitat-from-ruby).

{{< /note >}}

### Run InSpec profiles against Habitat

Execute your InSpec profiles against Habitat using the `--target` option to specify your configured Habitat connection:

```sh
inspec exec <PROFILE_NAME> --target habitat://<CONFIG_NAME>
```

In this command:

- `habitat://` tells InSpec to use the [train-habitat driver](https://github.com/inspec/train) to connect to Habitat
- `<CONFIG_NAME>` references the connection configuration defined in your InSpec configuration file

For example, to run a profile using a configuration named "production":

```sh
inspec exec profile-name --target habitat://production
```

## Habitat resources

{{< inspec_resources_filter >}}

The following Chef InSpec Habitat resources are available in this resource pack.

{{< inspec_resources section="habitat" platform="habitat" >}}
