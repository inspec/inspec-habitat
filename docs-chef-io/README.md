# Chef InSpec Habitat Resource Documentation

This is the home of the InSpec Habitat resource documentation found on
<https://docs.chef.io/inspec/resources/#habitat>.

We use [Hugo](https://gohugo.io/) to incorporate documentation from this repository into `chef/chef-web-docs` and deploy it on <https://docs.chef.io>.

## Documentation Content

### Resource Pages

All resource pages are located in `docs-chef-io/content/inspec/resources/`.

### New Pages

Make a new resource page by running `hugo new -k resource inspec/resources/RESOURCE_NAME.md` from the `docs-chef-io` directory.

You can also create a new page by duplicating an old page and then update the new page with content relevant to the new resource.

See our [style guide](https://docs.chef.io/style_index/) for suggestions on writing documentation.

#### Front Matter

At the top of each resource is a block of front matter, which Hugo uses to add a title to each page and locate each page in the left navigation menu in <docs.chef.io>. Below is an example of a page's front matter:

```toml
+++
title = "RESOURCE NAME resource"
platform = "habitat"
gh_repo = "inspec-habitat"

[menu.inspec]
title = "RESOURCE NAME"
identifier = "inspec/resources/habitat/RESOURCE NAME"
parent = "inspec/resources/habitat"
+++
```

`title` is the page title.

`platform = habitat` sorts each page into the correct category in the [Chef InSpec resources list page](https://docs.chef.io/inspec/resources/).

`gh_repo = "inspec-habitat"` adds an "[edit on GitHub]" link to the top of each page that links to the Markdown page in the inspec/inspec-habitat repository.

`[menu.inspec]` places the page in the Chef InSpec section of the left navigation menu in <docs.chef.io>. All the parameters following this configure the link in the left navigation menu to the page.

`title` is the title of page in the Chef InSpec menu.

`identifier` is the identifier for a page in the menu. It should formatted like this: `inspec/resources/habitat/resource name`.

`parent = "inspec/resources/habitat"` is the identifier for the section of the menu that the page will be found in. This value is set in the [chef-web-docs menu config](https://github.com/chef/chef-web-docs/blob/main/config/_default/menu.toml).

### Shortcodes

A shortcode is a file with a block of text that can be added in multiple places in our documentation by referencing the shortcode file name.

This documentation set has three shortcodes located in the `docs-chef-io/layouts/shortcodes` directory:

- inspec_matchers_link.md
- inspec_connecting_to_habitat.md
- inspec_habitat_installation.md
- inspec_habitat_experimental.md

Add a shortcode to a resource page by wrapping the filename, without the `.md` file suffix, in double curly braces and percent symbols. For example: `{{% inspec_matchers_link %}}`.

## Update the InSpec Habitat Repository Module In `chef/chef-web-docs`

We use [Hugo modules](https://gohugo.io/hugo-modules/) to build Chef's documentation
from multiple repositories.

A member of the Docs Team can update the inspec-habitat resource documentation at any time when new resources are ready to be added to <docs.chef.io>.

You can also submit a pull request to `chef/chef-web-docs` that updates the content in this repository.

In chef-web-docs, create a new branch and run:

```sh
hugo mod get -u github.com/habitat-sh/habitat/components/docs-chef-io
rm go.sum
hugo mod clean
hugo mod tidy
hugo mod vendor
```

This will update all of the inspec-habitat content in chef-web-docs.

## Local Development Environment

We use [Hugo](https://gohugo.io/), [Go](https://golang.org/), and[NPM](https://www.npmjs.com/)
to build the Chef Documentation website. You will need Hugo 0.93.1 or higher
installed and running to build and view our documentation.

To install Hugo, NPM, and Go on Windows and macOS:

- On macOS run: `brew install hugo node go`
- On Windows run: `choco install hugo-extended nodejs golang`

To install Hugo on Linux, run:

- `apt install -y build-essential`
- `snap install node --classic --channel=12`
- `snap install hugo --channel=extended`

## Preview InSpec Habitat Resource Documentation

### make serve

Run `make serve` to build a local preview of the InSpec Habitat resource documentation.
This will clone a copy of `chef/chef-web-docs` into the `docs-chef-io` directory.
That copy will be configured to build the InSpec Habitat resource documentation from the `docs-chef-io` directory
and live reload if any changes are made while the Hugo server is running.

- Run `make serve`
- go to <http://localhost:1313/inspec/resources/#habitat>

### Clean Your Local Environment

Run `make clean_all` to delete the cloned copy of chef/chef-web-docs.

## Documentation Feedback

If you need support, contact [Chef Support](https://www.chef.io/support/).

**GitHub issues**

Submit an issue to the [inspec-habitat repo](https://github.com/inspec/inspec-habitat/issues)
for "important" documentation bugs that may need visibility among a larger group,
especially in situations where a documentation bug may also surface a product bug.

Submit an issue to [chef-web-docs](https://github.com/chef/chef-web-docs/issues) for
documentation feature requests and minor documentation issues.
