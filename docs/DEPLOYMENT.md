# Deployment Workflows

This guide explains how to deploy **CL-web-components** depending on what changed.

---

# Prerequisites

None for documentation changes.

CDN deployment runs in GitHub Actions using an assumed AWS role, configured
through these repository secrets:

```
AWS_ROLE_TO_ASSUME
AWS_BUCKET
AWS_DISTRIBUTION
```

No local AWS credentials and no `media.env` file are needed.

---
  
# Deploy Documentation Changes

Use this workflow when **only documentation (`.md`) files have changed**.

Documentation is published automatically. Pushing to `main` triggers the
`.github/workflows/docs.yml` GitHub Actions workflow, which
runs Pandoc over every `*.md` file, rebuilds the Pagefind search index, and
deploys the result straight to GitHub Pages. There is no `gh-pages` branch and
no publishing script to run.

## Step 1. Preview (optional)

The site is built entirely by `.github/workflows/docs.yml`. Pandoc renders
every `docs/*.md` page plus the cmt-generated Markdown at the repository root,
the demo pages and runtime assets are copied in, and Pagefind rebuilds the
search index.

Opening a pull request builds the site without publishing it. The run's
`github-pages` artifact is the exact site that would be deployed, so
downloading it is the most accurate preview available.

To check a single page locally:

```bash
pandoc --metadata title=user_manual -s --to html5 docs/user_manual.md \
  -o /tmp/user_manual.html \
  --lua-filter=pandoc/links-to-html.lua \
  --lua-filter=pandoc/add-col-scope.lua \
  --template=pandoc/page.tmpl
```

Documentation sources live in `docs/`, and only `docs/` is published.
`docs/README.md` becomes the site's `index.html`. The root `README.md` is
written for people browsing the repository on GitHub and is deliberately not
rendered into the site. The Pandoc template and filters live in `pandoc/`.
`llm_notes/` stays in the repository but is not published.

## Step 2. Save and push your working branch

If you added **new files**, stage them first:

```bash
git add <filename>
```

Then commit and push:

```bash
git commit -m "your commit message"
git push
```

## Step 3. Confirm the deployment

Once your change is on `main`, watch the run finish under the repository's
**Actions** tab, or from the command line:

```bash
gh run watch
```

The site updates at <https://caltechlibrary.github.io/CL-web-components/> when the
workflow completes, typically within a minute.

---

# Deploy Updated Web Component Code

Use this workflow when **component code in `src/` has changed** and needs to be
deployed to the CDN.

## Step 1. Edit and push

Edit the component under `src/`, then commit and push:

```bash
git commit -m "your commit message"
git push
```

The bundles are build output. They are compiled by CI into `dist/`, which is
gitignored, so there is nothing to rebuild or commit by hand.

## Step 2. Publish to the CDN

The **Publish components to CDN** workflow runs automatically when a GitHub
release is published. To push the current `main` without cutting a release,
run it manually from the Actions tab -- it accepts a `dry_run` option that
lists what would be uploaded without uploading it.

The workflow bundles the components, uploads them and `css/*.css` under
`/cl-webcomponents/` in the bucket, and invalidates the CloudFront cache for
that prefix.

---

# Deploy a New Release

You do two things: choose how the version increments, and approve the draft.

## Step 1. Run the release workflow

From the Actions tab, run **Draft release** and pick `patch`, `minor` or
`major`. From the command line:

```bash
gh workflow run release.yml -f bump=patch
```

There is an optional `version` input for the rare case where you need an exact
number rather than an increment.

The workflow works out the next version from `codemeta.json`, then makes a
single commit containing the bumped `codemeta.json`, the regenerated
`CITATION.cff`. It tags that commit, builds the bundles and the zip, and opens
a **draft** release.

`README.md` is not regenerated: it is hand-written and owned by this
repository. Only machine-readable files are derived from `codemeta.json`.

`src/version.js` is not committed. `deno task build` generates it from
`codemeta.json` before bundling, so the version, release date and commit hash
baked into every bundle always match the commit being released.

Everything lands in one commit, so the tag can never point at a half-updated
tree.

## Step 2. Write the notes and publish

Open the draft, write the release notes in GitHub's editor -- it starts with
the auto-generated commit list -- and publish:

```bash
gh release view --web
```

Publishing is the only manual step and the only irreversible one. It triggers
**Publish components to CDN**, which uploads the bundles to
`media.library.caltech.edu` and invalidates the CloudFront cache.

`codemeta.json` records the release URL in `releaseNotes` rather than a copy of
the prose, so the notes live in exactly one place.

---

# Command Reference

| Task | Command |
|-----|---------|
| Compile source code | `deno task build` |
| Run the tests | `deno test --allow-read` |
| Deploy components to the CDN | Actions -> Publish components to CDN |
| Cut a release | `gh workflow run release.yml -f bump=patch`, then publish the draft |

---

