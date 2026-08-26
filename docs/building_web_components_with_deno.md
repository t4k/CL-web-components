
# Building Web Components with Deno

Web components run in the browser as JavaScript. Generally speaking their built as independent modules. There is a growing library of standard modules at <https://jsr.io>. The standard modules work in Deno as well as the browser.  This includes useful libraries like `@std/csv`, `@std/path` and `@std/yaml`. The referencing an import of these by full URLs is not ideal. It makes much more sense to take advantage Deno which provides additional functionality like check, lint, fmt and bundle. The last item is important for web components. With bundle we can generate a a web component including it's dependent modules. This gives us much more reliability in deployments and flexibility of moving code between browser and server.

## Un-bundled sources

If you are working on a web component the un-bundled source should be placed in the `src/` directory. This allows you to include remote and local modules easily. The build process maintains the `version.js` module which includes the versioning of this repository as well as license text. 

Current the following component(s) **require** bundling due to external dependencies.

- [src/textarea-csv.js](src/textarea-csv.js), uses `@std/csv`

You can build local bundles and test versions using the following Deno task command.

~~~shell
deno task build
~~~

## Building CL-web-components

Component bundles are built with a Deno task:

~~~shell
deno task build
~~~

That writes the bundles into `dist/`, which is gitignored. You rarely need to
run it by hand: GitHub Actions builds the bundles for the documentation site,
for the CDN upload and for the release zip.

The documentation website is built and deployed by GitHub Actions, so there is
no local website step either.

Releases are cut from `codemeta.json` -- bump `version`, write `releaseNotes`,
push, then publish the draft release that appears. See [DEPLOYMENT](DEPLOYMENT.md).

NOTE: the sources are in `src/`. Fixes and additions go there. The bundles in
`dist/` are build output and are never committed.
