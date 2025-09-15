+++
title = "About Chef InSpec Habitat resources"
platform = "habitat"
draft = false
gh_repo = "inspec-habitat"
linkTitle = "Habitat resources"
summary = "Chef InSpec resources for auditing Habitat packages and services"

[menu.habitat]
    title = "About"
    identifier = "inspec/resources/habitat/About"
    parent = "inspec/resources/habitat"
+++

Use the Chef InSpec Habitat resources to test Chef Habitat packages and services.

This resource pack is in the early stages of research and development. Functionality may be defective, incomplete, or be withdrawn in the future. If you are interested in helping this project mature, please join the conversation or contribute code at the [inspec-habitat project](https://github.com/inspec/inspec-habitat).

## Prerequisites

- Chef InSpec v4.7.3 or later
- A running Habitat Supervisor that you can access using SSH, the HTTP API, or (ideally) both.

## Target Habitat

The `inspec-habitat` resources use whatever available method to query Habitat to obtain information, either with the `hab` CLI using SSH or with the HTTP API gateway. `inspec-habitat` uses the `hab` command line program to obtain certain information; currently it must use SSH to connect to the machine where `hab` is installed. Additionally, some information is only available from the Supervisor HTTP API.

### Define Habitat connections

To connect to Habitat, define your connection options using the [InSpec configuration file](https://docs.chef.io/inspec/config/).
You create as many sets of configuration options as you like, for example one for a development, one for staging, and one for production.

Define your connection options in the `~/.inspec/config.json` using the following format:

```json
{
  "file_version": "1.1",
  "credentials": {
    "habitat": {
      "<CONFIG_NAME>": {
        "api_url": "http://dev-hab.example.com",
        "cli_ssh_host": "dev-hab.example.com",
        "cli_ssh_user": "username",
        "cli_ssh_key_files": "~/.ssh/KEYNAME"
      }
    }
  }
}
```

Habitat Supervisor API connection options:

`api_url`
: The URL to the Habitat Supervisor API. If no port is specified, it defaults to `9631`. If you omit `api_url`, InSpec assumes the Supervisor API is not available.

`api_auth_token`
: The bearer token for the Habitat Supervisor API. If your Habitat Supervisor is configured to expect a token, define it here.

Habitat SSH connection options:

`cli_ssh_host`
: The IP or hostname of the machine to connect to. If omitted, it is assumed that the CLI interface is not available.

`cli_ssh_user`
: The SSH username to connect as. If omitted, it uses the OS user that the `inspec` process is running as.

`cli_ssh_key_files`
: The path or paths to key files to use when authenticating with SSH. Define this as an array or single string.

{{< note >}}

The `train-habitat` driver has many additional connection options. For further details, see the [Ruby `train-habitat` documentation](https://github.com/inspec/train-habitat#using-train-habitat-from-ruby).

{{< /note >}}

### Run a profile against Habitat

To run a profile against Chef Habitat, use the `-t` option (`--target`) to specify the Habitat target:

```sh
inspec exec <PROFILE_NAME> --target habitat://<CONFIG_NAME>
```

Within the target `habitat://<CONFIG_NAME>`, `habitat://` instructs InSpec to use the [train-habitat driver](https://github.com/inspec/train) and the `<CONFIG_NAME>` label selects the matching set of options from the InSpec configuration file.

## Habitat resources

{{< inspec_resources_filter >}}

The following Chef InSpec Habitat resources are available in this resource pack.

{{< inspec_resources section="habitat" platform="habitat" >}}
