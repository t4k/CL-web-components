# CL-web-components

These are the Web Components Caltech Library uses across its sites and
projects — sortable tables, editable CSV fields, A-to-Z lists, the standard
library footer, and a few others. Each is a custom HTML element you can drop
into a page without adopting a framework or a build step.

This site documents what each component does, how to configure it, and what it
looks like in use. Every component page links to a working demo you can view
source on.

## Quick start

One script tag loads every component and registers each custom element:

```html
<script type="module"
        src="https://caltechlibrary.github.io/CL-web-components/mod.js"></script>
```

From there, use the elements directly in your markup. Each component page
below shows the attributes it accepts.

## Where to start

**Looking for a specific component?** The [User Manual](user_manual.html) is
the full index — every component, its documentation page, its source file, and
its demos.

**Working on the components themselves?** [Developers](DEVELOPERS.html) covers
how the project is put together, and [Deployment](DEPLOYMENT.html) covers how
it is built and released.

## How these docs are organized

**Component pages** — one per component, each covering attributes, slots,
styling hooks, and behavior. Linked from the User Manual.

**Demos** — a live page per component, sometimes several, showing the common
configurations. Named `demo_*` and reachable from each component's page.

**Background** — how we approach the recurring problems of building a
component library:

- [Web component naming](web_component_naming.html)
- [Integrating CSS in web components](integrating_CSS_in_web_components.html)
- [Building web components with Deno](building_web_components_with_deno.html)
- [Enhancing code blocks](enhance_code_blocks.html)

**Project documentation** — [Developers](DEVELOPERS.html) and
[Deployment](DEPLOYMENT.html), for people changing the components rather than
using them.

Every page on this site is searchable from the search box.

## Elsewhere

The [repository on GitHub](https://github.com/caltechlibrary/CL-web-components)
holds the source, the release history, and the issue tracker. Its README covers
installation, repository layout, and how to contribute.
