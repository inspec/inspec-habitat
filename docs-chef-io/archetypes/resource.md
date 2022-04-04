+++
title = "{{ .Name }} resource"
draft = false
gh_repo = "inspec"
platform = "habitat"

[menu]
  [menu.inspec]
    title = "{{ .Name }}"
    identifier = "inspec/resources/habitat/{{ .Name }}"
    parent = "inspec/resources/habitat"
+++
{{/* Run `hugo new -k resource inspec/resources/RESOURCE_NAME.md` to generate a new resource page. */}}

Use the `{{ .Name }}` Chef InSpec audit resource to test the configuration of...

New in version X.Y.X of this resource pack.

## Status: EXPERIMENTAL

{{% inspec_habitat_experimental %}}

## Installation

{{% inspec_habitat_installation %}}

## Connecting to Chef Habitat

{{% inspec_connecting_to_habitat %}}

### API Versus CLI Access

Chef Habitat exposes certain data via the CLI, and other data via the HTTP Gateway API....

## Syntax

```ruby
describe {{ .Name }} do
  #...
end
```

## Parameters

`PARAMETER`
: PARAMETER DESCRIPTION

`PARAMETER`
: PARAMETER DESCRIPTION

## Properties

`PROPERTY`
: PROPERTY DESCRIPTION

`PROPERTY`
: PROPERTY DESCRIPTION

## Examples

**EXAMPLE DESCRIPTION**

```ruby
describe {{ .Name }} do
  #...
end
```

**EXAMPLE DESCRIPTION**

```ruby
describe {{ .Name }} do
  #...
end
```

## Matchers

{{% inspec_matchers_link %}}
